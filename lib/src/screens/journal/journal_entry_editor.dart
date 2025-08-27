import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';
import '../../providers/journal_providers.dart';
import '../../providers/auth_providers.dart';

class JournalEntryEditor extends ConsumerStatefulWidget {
  final String? entryId;

  const JournalEntryEditor({super.key, this.entryId});

  @override
  ConsumerState<JournalEntryEditor> createState() => _JournalEntryEditorState();
}

class _JournalEntryEditorState extends ConsumerState<JournalEntryEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();
  final FocusNode _tagFocus = FocusNode();

  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _tagController = TextEditingController();

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);

    // Load existing entry if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntryIfNeeded();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    _tagFocus.dispose();
    super.dispose();
  }

  void _loadEntryIfNeeded() async {
    if (widget.entryId != null && widget.entryId != 'new') {
      final entryAsync = ref.read(journalEntryProvider(widget.entryId!));
      entryAsync.when(
        data: (entry) {
          if (entry != null && mounted) {
            ref.read(journalEntryControllerProvider.notifier).loadEntry(entry);
            _updateControllers();
          }
        },
        loading: () {},
        error: (error, stack) {
          // Handle error if needed
        },
      );
    }
  }

  void _updateControllers() {
    final state = ref.read(journalEntryControllerProvider);
    _titleController.text = state.title;
    _contentController.text = state.content;
    _hasUnsavedChanges = false;
  }

  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }

    ref
        .read(journalEntryControllerProvider.notifier)
        .setTitle(_titleController.text);
    ref
        .read(journalEntryControllerProvider.notifier)
        .setContent(_contentController.text);
  }

  @override
  Widget build(BuildContext context) {
    final entryState = ref.watch(journalEntryControllerProvider);
    final authState = ref.watch(authStateProvider);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasUnsavedChanges) {
          _showUnsavedChangesDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.entryId == 'new' ? 'New Entry' : 'Edit Entry'),
          actions: [
            if (entryState.isExisting)
              IconButton(
                icon: Icon(
                  entryState.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: entryState.isFavorite ? AppColors.error : null,
                ),
                onPressed: () {
                  ref
                      .read(journalEntryControllerProvider.notifier)
                      .toggleFavorite();
                },
              ),
            if (entryState.isExisting)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(),
              ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: entryState.isValid ? () => _saveEntry() : null,
            ),
          ],
        ),
        body: authState.when(
          data: (user) {
            if (user == null) {
              return const Center(
                child: Text('Please sign in to write journal entries'),
              );
            }
            return _buildEditor(user.uid);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildEditor(String userId) {
    final entryState = ref.watch(journalEntryControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entry metadata
          if (entryState.isExisting) ...[
            _buildMetadataCard(),
            const SizedBox(height: 16),
          ],

          // Title field
          _buildTitleField(),
          const SizedBox(height: 16),

          // Content field
          _buildContentField(),
          const SizedBox(height: 16),

          // Tags section
          _buildTagsSection(),
          const SizedBox(height: 16),

          // Writing tools
          _buildWritingTools(),
          const SizedBox(height: 16),

          // Save button
          _buildSaveButton(userId),

          // Error display
          if (entryState.error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: AppColors.error.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  entryState.error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataCard() {
    final entryState = ref.watch(journalEntryControllerProvider);

    return Card(
      color: AppColors.neutralGray50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.neutralGray600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entryState.createdAt != null
                    ? 'Created ${_formatDateTime(entryState.createdAt!)}'
                    : 'New entry',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutralGray600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title', style: AppTypography.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          focusNode: _titleFocus,
          decoration: const InputDecoration(
            hintText: 'Enter a title for your entry...',
            border: OutlineInputBorder(),
          ),
          style: AppTypography.titleMedium,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (value) {
            FocusScope.of(context).requestFocus(_contentFocus);
          },
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Content', style: AppTypography.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          focusNode: _contentFocus,
          decoration: const InputDecoration(
            hintText: 'Start writing your thoughts...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          style: AppTypography.bodyLarge,
          maxLines: null,
          minLines: 8,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 14,
              color: AppColors.neutralGray500,
            ),
            const SizedBox(width: 4),
            Text(
              'Word count: ${_getWordCount(_contentController.text)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutralGray500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    final entryState = ref.watch(journalEntryControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: AppTypography.labelLarge),
        const SizedBox(height: 8),

        // Add tag field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                focusNode: _tagFocus,
                decoration: const InputDecoration(
                  hintText: 'Add a tag...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) => _addTag(value),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addTag(_tagController.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Current tags
        if (entryState.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entryState.tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeTag(tag),
                  ),
                )
                .toList(),
          )
        else
          Text(
            'No tags added yet',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutralGray500,
            ),
          ),
      ],
    );
  }

  Widget _buildWritingTools() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Writing Tools', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildToolButton(
                  'Gratitude',
                  () => _insertTemplate(
                    '\n\n**What I\'m grateful for:**\n- \n- \n- \n',
                  ),
                ),
                _buildToolButton(
                  'Reflection',
                  () => _insertTemplate(
                    '\n\n**Reflection Questions:**\n- How did I feel today?\n- What did I learn?\n- What would I do differently?\n',
                  ),
                ),
                _buildToolButton(
                  'Goals',
                  () => _insertTemplate(
                    '\n\n**Goals for tomorrow:**\n- \n- \n- \n',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(String label, VoidCallback onPressed) {
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }

  Widget _buildSaveButton(String userId) {
    final entryState = ref.watch(journalEntryControllerProvider);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: entryState.isValid && !entryState.isSaving
            ? () => _saveEntry()
            : null,
        child: entryState.isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(entryState.isExisting ? 'Update Entry' : 'Save Entry'),
      ),
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty) {
      ref.read(journalEntryControllerProvider.notifier).addTag(trimmedTag);
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    ref.read(journalEntryControllerProvider.notifier).removeTag(tag);
  }

  void _insertTemplate(String template) {
    final currentText = _contentController.text;
    final newText = currentText + template;
    _contentController.text = newText;
    _contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
    FocusScope.of(context).requestFocus(_contentFocus);
  }

  Future<void> _saveEntry() async {
    final authState = ref.read(authStateProvider);
    final userId = authState.value?.uid ?? 'guest';

    final success = await ref
        .read(journalEntryControllerProvider.notifier)
        .saveEntry(userId);

    if (success && mounted) {
      _hasUnsavedChanges = false;
      ref.invalidate(journalEntriesProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate back after saving
      context.pop();
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final success = await ref
                  .read(journalEntryControllerProvider.notifier)
                  .deleteEntry();
              if (success && mounted) {
                ref.invalidate(journalEntriesProvider);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Entry deleted')));

                context.pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  int _getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
