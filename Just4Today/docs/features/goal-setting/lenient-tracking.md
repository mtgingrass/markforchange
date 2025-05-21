# Lenient Tracking - SetGoalView

## Overview
Lenient tracking provides flexibility in when habits are completed while maintaining accountability through weekly quotas. This feature acknowledges that life doesn't always follow a rigid schedule.

## Core Concept
- Focus on weekly completion count
- Flexible day-to-day scheduling
- Maintains overall consistency
- Supports realistic habit formation

## Implementation Details

### Tracking Logic
- **Weekly Count**:
  - Tracks total completions per week
  - Week boundaries at midnight Sunday
  - Counts any completion towards weekly goal
  - Ignores specific day assignments

### Day Selection
- **Purpose**: 
  - Suggested schedule
  - Personal planning aid
  - Visual reminder
- **Behavior**:
  - Days are non-binding
  - Used for personal reference
  - Help maintain routine

## User Interface

### Toggle Component
- Clear on/off state
- Accessible touch target
- Visual feedback on change

### Information Display
- Expandable info box
- Clear explanation text
- Visual examples if needed

### Help Text
> With lenient tracking, it doesn't matter which days you do the habit.
> As long as you complete it the desired number of times in a week,
> it is counted as successful. You can choose the days of week for your own tracking,
> but the count is what matters with lenient tracking enabled.

## Use Cases

### Ideal Scenarios
- Unpredictable schedules
- Shift work
- Travel frequently
- Variable availability

### Example Applications
- **Workout Goal**:
  - 3x per week
  - Any days acceptable
  - Weekly reset on Sunday
  - Maintains flexibility

- **Reading Goal**:
  - 4x per week
  - Adaptable to daily energy
  - Counts total weekly sessions
  - Accommodates busy days

## Streak Handling
- Streak continues if weekly quota met
- Week boundaries respect local timezone
- Clear feedback on quota status
- Weekly progress tracking

## Best Practices
- Enable for flexible goals
- Use with weekly targets
- Combine with realistic quotas
- Keep day selection as guide 