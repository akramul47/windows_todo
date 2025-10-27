# Habits Feature

## Overview
The Habits feature allows users to track daily and measurable habits with a clean, modern interface inspired by habit tracking apps.

## Features

### ✅ Core Functionality
- **Boolean Habits**: Simple yes/no tracking (e.g., "Did you meditate?")
- **Measurable Habits**: Track numeric values with custom units (e.g., "5 miles run", "50 pages read")
- **Weekly View**: See your last 7 days at a glance with visual indicators
- **Habit Details**: Comprehensive analytics including:
  - Current streak tracker
  - Best streak (all-time record)
  - 30-day completion rate
  - Total completed days
  - Calendar heatmap (5-week view)
  - Visual progress bars

### 🎨 UI/UX Features
- **Glass-morphism Design**: Modern translucent cards matching the app theme
- **Color Customization**: Choose from 10 vibrant colors for each habit
- **Responsive Layout**: Optimized for mobile, tablet, and desktop
- **Dark/Light Mode**: Full theme support
- **Smooth Animations**: Fade-in effects and hover states
- **Accessibility**: Keyboard navigation and screen reader support

### 💾 Data Management
- **Local Storage**: All data persisted using SharedPreferences
- **Auto-save**: Changes saved immediately
- **Archive Support**: Archive old habits without deleting
- **History Tracking**: Unlimited history storage

## Usage

### Creating a Habit
1. Tap the **+ New** button in the Habits screen
2. Enter a habit name (e.g., "Meditate")
3. Choose type:
   - **Yes/No**: Simple boolean tracking
   - **Measurable**: Numeric with unit (e.g., "miles", "pages")
4. Select a color to personalize
5. Tap **Create**

### Tracking Progress
- **Boolean Habits**: Tap the day cell to toggle ✓ or ✗
- **Measurable Habits**: Tap the day cell to enter a numeric value

### Viewing Analytics
- Tap any habit row to view detailed statistics
- See streaks, completion rates, and visual history

### Managing Habits
- **Archive**: Tap the archive icon in the header to toggle archived habits view
- **Edit**: Long-press a habit row (coming soon)
- **Delete**: Swipe left on habit row (coming soon)

## Technical Details

### Architecture
```
lib/
├── models/
│   └── habit.dart              # Habit data model with streak logic
├── providers/
│   └── habit_provider.dart     # State management (ChangeNotifier)
├── screens/
│   ├── habits_screen.dart      # Main habits list view
│   └── habit_detail.dart       # Analytics & detail screen
├── widgets/
│   └── habit_row.dart          # Reusable habit list item
└── services/
    └── storage_service.dart    # Persistence (habits methods added)
```

### Data Model
Each `Habit` contains:
- `id`: Unique identifier
- `name`: Display name
- `color`: Custom color (Color object)
- `icon`: IconData for visual identity
- `type`: Boolean or Measurable
- `unit`: Unit string for measurable habits
- `history`: Map<String, dynamic> of date -> value
- `createdAt`: Creation timestamp
- `isArchived`: Archive status

### Persistence
Habits are stored in JSON format using SharedPreferences:
```dart
await storageService.saveHabits(habitList.habits);
final habits = await storageService.loadHabits();
```

## Future Enhancements
- [ ] Reminders/notifications
- [ ] Weekly/monthly goals
- [ ] Habit templates
- [ ] Export/import data
- [ ] Habit groups/categories
- [ ] Advanced statistics (charts, trends)
- [ ] Swipe gestures for quick actions
- [ ] Long-press context menu

## Screenshots
*(See attached images showing habit tracking in action)*

---
Built with ❤️ for productive habit formation
