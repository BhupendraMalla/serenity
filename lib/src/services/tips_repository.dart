import 'dart:async';
import '../models/tip_simple.dart';

abstract class TipsRepository {
  Future<List<Tip>> getAllTips();
  Future<List<Tip>> getTipsByCategory(TipCategory category);
  Future<List<Tip>> getFeaturedTips();
  Future<Tip?> getTipById(String tipId);
  Future<DailyQuote?> getTodayQuote();
  Future<List<DailyQuote>> getQuotes();
}

class SimpleTipsRepositoryImpl implements TipsRepository {
  final List<Tip> _tips = _generateSampleTips();
  final List<DailyQuote> _quotes = _generateSampleQuotes();

  static List<Tip> _generateSampleTips() {
    final now = DateTime.now();
    
    return [
      // Stress Management Tips
      Tip(
        id: 'stress_01',
        title: '5-4-3-2-1 Grounding Technique',
        content: '''When you feel overwhelmed, try this simple grounding exercise:

• **5 things you can see** - Look around and name 5 objects you can see
• **4 things you can touch** - Feel the texture of your clothes, a wall, or your phone
• **3 things you can hear** - Listen for sounds around you like traffic, birds, or your breathing
• **2 things you can smell** - Notice any scents in the air
• **1 thing you can taste** - Maybe the lingering taste of coffee or mint

This technique helps bring your focus back to the present moment and can reduce anxiety and stress within minutes.''',
        category: TipCategory.stress,
        tags: ['grounding', 'anxiety', 'mindfulness', 'quick'],
        author: 'Dr. Sarah Chen',
        source: 'Mindfulness Research Institute',
        createdAt: now.subtract(const Duration(days: 1)),
        isFeatured: true,
      ),

      Tip(
        id: 'stress_02',
        title: 'Progressive Muscle Relaxation',
        content: '''This technique involves tensing and then relaxing different muscle groups:

**How to do it:**
1. Start with your toes - tense for 5 seconds, then relax
2. Move to your calves, thighs, abdomen, arms, and face
3. Focus on the contrast between tension and relaxation
4. Breathe deeply throughout the process

**Benefits:**
- Reduces physical tension
- Improves sleep quality
- Lowers stress hormones
- Increases body awareness

Practice this for 10-15 minutes daily, especially before bed.''',
        category: TipCategory.stress,
        tags: ['relaxation', 'tension', 'sleep', 'body'],
        author: 'Dr. Michael Torres',
        createdAt: now.subtract(const Duration(days: 5)),
      ),

      // Anxiety Management
      Tip(
        id: 'anxiety_01',
        title: 'The 3-3-3 Rule for Anxiety',
        content: '''When anxiety strikes, use this simple rule:

**Name 3 things you can see**
Look around your environment and identify three specific objects. Describe them in detail mentally.

**Name 3 sounds you can hear**
Listen carefully to your surroundings. Maybe it's air conditioning, footsteps, or your own breathing.

**Move 3 parts of your body**
Wiggle your fingers, roll your shoulders, or tap your feet. Physical movement helps ground you.

This technique interrupts the anxiety cycle and brings your attention back to the present moment.''',
        category: TipCategory.anxiety,
        tags: ['anxiety', 'panic', 'grounding', 'immediate'],
        author: 'Emma Watson, LCSW',
        source: 'Anxiety and Depression Association',
        createdAt: now.subtract(const Duration(days: 3)),
        isFeatured: true,
      ),

      // Sleep Hygiene
      Tip(
        id: 'sleep_01',
        title: 'Creating the Perfect Sleep Environment',
        content: '''Your bedroom environment significantly impacts sleep quality:

**Temperature:** Keep it cool (60-67°F/15-19°C)
**Darkness:** Use blackout curtains or an eye mask
**Quiet:** Consider earplugs or white noise
**Comfort:** Invest in quality pillows and mattress

**Pre-sleep routine:**
- No screens 1 hour before bed
- Dim the lights 30 minutes before sleep
- Try reading, gentle stretching, or meditation
- Keep a consistent sleep schedule

**Avoid:**
- Caffeine after 2 PM
- Large meals 3 hours before bed
- Alcohol before sleep
- Intense exercise close to bedtime''',
        category: TipCategory.sleep,
        tags: ['sleep', 'environment', 'routine', 'hygiene'],
        author: 'Dr. Sleep Specialist',
        createdAt: now.subtract(const Duration(days: 7)),
        isFeatured: true,
      ),

      // Mindfulness
      Tip(
        id: 'mindfulness_01',
        title: 'Mindful Breathing for Beginners',
        content: '''Start your mindfulness journey with simple breathing exercises:

**Basic Technique:**
1. Sit comfortably with eyes closed or softly focused
2. Breathe naturally - don't force it
3. Notice the sensation of breathing
4. When mind wanders, gently return to breath

**4-7-8 Breathing:**
- Inhale for 4 counts
- Hold for 7 counts  
- Exhale for 8 counts
- Repeat 3-4 times

**Benefits:**
- Reduces stress and anxiety
- Improves focus and concentration
- Lowers blood pressure
- Enhances emotional regulation

Start with just 5 minutes daily and gradually increase.''',
        category: TipCategory.mindfulness,
        tags: ['breathing', 'meditation', 'focus', 'beginner'],
        author: 'Zen Master Li',
        createdAt: now.subtract(const Duration(days: 10)),
      ),

      // Productivity & Focus
      Tip(
        id: 'productivity_01',
        title: 'The Pomodoro Technique for Mental Clarity',
        content: '''Improve focus and reduce mental fatigue with this time management method:

**How it works:**
1. Work for 25 minutes (one "pomodoro")
2. Take a 5-minute break
3. Repeat for 4 cycles
4. Take a longer 15-30 minute break

**During work periods:**
- Focus on one task only
- Remove distractions (phone, notifications)
- If you think of something else, write it down for later

**During breaks:**
- Step away from your workspace
- Stretch, walk, or do breathing exercises
- Avoid screens if possible

This technique prevents burnout and maintains mental energy throughout the day.''',
        category: TipCategory.productivity,
        tags: ['focus', 'time-management', 'breaks', 'energy'],
        author: 'Productivity Expert Jane',
        createdAt: now.subtract(const Duration(days: 12)),
      ),

      // Relationships
      Tip(
        id: 'relationships_01',
        title: 'Active Listening for Better Relationships',
        content: '''Improve your relationships with these listening skills:

**Give full attention:**
- Put away devices and distractions
- Make eye contact when culturally appropriate
- Use open body language

**Reflect and clarify:**
- "What I hear you saying is..."
- "Help me understand..."
- Ask open-ended questions

**Avoid these listening blockers:**
- Planning your response while they speak
- Judging or criticizing mentally
- Interrupting or finishing their sentences
- Offering immediate solutions

**Show you're listening:**
- Nod and use affirming sounds ("mm-hmm")
- Reflect their emotions ("That sounds frustrating")
- Summarize what they've shared

Quality listening builds trust and deepens connections.''',
        category: TipCategory.relationships,
        tags: ['communication', 'listening', 'empathy', 'connection'],
        author: 'Dr. Relationship Expert',
        createdAt: now.subtract(const Duration(days: 15)),
      ),

      // General wellness
      Tip(
        id: 'general_01',
        title: 'The Power of Gratitude Practice',
        content: '''Regular gratitude practice can significantly improve mental health:

**Simple gratitude exercises:**
- Write 3 things you're grateful for each morning
- Keep a gratitude jar - add notes throughout the week
- Share appreciation with someone daily
- Take gratitude photos of meaningful moments

**Benefits supported by research:**
- Increases happiness and life satisfaction
- Improves sleep quality
- Strengthens immune system
- Enhances relationships
- Reduces depression and anxiety

**Make it specific:**
Instead of "I'm grateful for my family," try "I'm grateful for my sister's encouraging text this morning."

**Include challenges:**
Find something to appreciate even in difficult situations - this builds resilience.''',
        category: TipCategory.general,
        tags: ['gratitude', 'happiness', 'wellbeing', 'practice'],
        author: 'Dr. Positive Psychology',
        createdAt: now.subtract(const Duration(days: 20)),
        isFeatured: true,
      ),

      Tip(
        id: 'general_02',
        title: 'Digital Detox for Mental Health',
        content: '''Take breaks from technology to improve your mental wellbeing:

**Signs you might need a digital detox:**
- Checking phone first thing in the morning
- Feeling anxious without your device
- Comparing yourself to others on social media
- Difficulty concentrating without notifications

**Start small:**
- Phone-free meals
- No screens 1 hour before bed
- Designated phone-free zones in your home
- One day per week with minimal technology

**Replace screen time with:**
- Reading physical books
- Outdoor activities
- Face-to-face conversations
- Creative hobbies
- Physical exercise

**Benefits:**
- Better sleep quality
- Improved focus and productivity
- Reduced anxiety and FOMO
- More meaningful relationships
- Greater presence and mindfulness

Remember: Technology should serve you, not control you.''',
        category: TipCategory.general,
        tags: ['digital-detox', 'technology', 'mindfulness', 'balance'],
        author: 'Digital Wellness Coach',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
    ];
  }

  static List<DailyQuote> _generateSampleQuotes() {
    final now = DateTime.now();
    
    return [
      DailyQuote(
        id: 'quote_01',
        quote: 'The present moment is the only time over which we have dominion.',
        author: 'Thích Nhất Hạnh',
        source: 'The Miracle of Mindfulness',
        category: TipCategory.mindfulness,
        date: now,
      ),
      DailyQuote(
        id: 'quote_02',
        quote: 'You have been assigned this mountain to show others it can be moved.',
        author: 'Mel Robbins',
        category: TipCategory.stress,
        date: now.subtract(const Duration(days: 1)),
      ),
      DailyQuote(
        id: 'quote_03',
        quote: 'Gratitude turns what we have into enough.',
        author: 'Anonymous',
        category: TipCategory.general,
        date: now.subtract(const Duration(days: 2)),
      ),
      DailyQuote(
        id: 'quote_04',
        quote: 'Peace comes from within. Do not seek it without.',
        author: 'Buddha',
        category: TipCategory.mindfulness,
        date: now.subtract(const Duration(days: 3)),
      ),
      DailyQuote(
        id: 'quote_05',
        quote: 'Progress, not perfection.',
        author: 'Anonymous',
        category: TipCategory.general,
        date: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  @override
  Future<List<Tip>> getAllTips() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_tips)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Tip>> getTipsByCategory(TipCategory category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _tips.where((tip) => tip.category == category).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Tip>> getFeaturedTips() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _tips.where((tip) => tip.isFeatured).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Tip?> getTipById(String tipId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _tips.firstWhere((tip) => tip.id == tipId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DailyQuote?> getTodayQuote() async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    // Get today's quote based on the current date
    final today = DateTime.now();
    final todayQuotes = _quotes.where((quote) => 
      quote.date.year == today.year &&
      quote.date.month == today.month &&
      quote.date.day == today.day
    ).toList();

    if (todayQuotes.isNotEmpty) {
      return todayQuotes.first;
    }

    // If no quote for today, return a random one
    if (_quotes.isNotEmpty) {
      final dayOfYear = today.difference(DateTime(today.year)).inDays;
      return _quotes[dayOfYear % _quotes.length];
    }

    return null;
  }

  @override
  Future<List<DailyQuote>> getQuotes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_quotes)..sort((a, b) => b.date.compareTo(a.date));
  }
}