# Streak Logic - HabitListView

## Streak Calculation

### Daily Reset
- Streak check occurs at midnight local time
- Habits not marked complete by end of day:
  - Streak resets to 0
  - Previous streak saved for history
  - Record remains unchanged if not exceeded

### Streak Increment Rules
- Streak increases when:
  - Habit marked complete for current day
  - Completed within the day's timeframe
  - Previous day was either completed or start of streak

### Record Tracking
- Record updates automatically when:
  - Current streak exceeds previous record
  - Manual override is performed
- Record persists even when streak breaks
- Historical records maintained for statistics

## Special Cases

### Just for Today Goals
- No streak tracking
- Completion status resets daily
- No record keeping

### Lenient Tracking
- Streak continues if weekly quota met
- Days between completions don't break streak
- Weekly boundaries considered for streak calculation

## Manual Adjustments

### Streak Override
- Date picker for start date
- Automatically calculates streak length
- Validates against completion history
- Updates record if applicable

### Reset Actions
- Streak reset: Sets current streak to 0
- Record reset: Clears all-time best
- Both maintain historical data for statistics

## Data Management

### Persistence
- Streak data saved immediately on changes
- Backed up with app data
- Maintains history for statistics

### Migration
- Handles timezone changes
- Preserves streak data during updates
- Maintains integrity during data structure changes 