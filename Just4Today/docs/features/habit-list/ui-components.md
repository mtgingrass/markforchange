# UI Components - HabitListView

## Top Bar
- **Title**: "Your Habits"
- **Action Buttons**:
  - "+ Add Habit" (top right)
  - "Global Settings" (optional)

## HabitRowView Component
### Layout
- **Habit Title**
  - Primary text
  - Clear, readable font
  - Supports long titles with appropriate truncation

- **Streak Display**
  - Format: "Streak: [number] 🔥 • Record: [number]"
  - Current streak prominently displayed
  - All-time record shown alongside

- **Completion Status**
  - Checkbox or "Mark Done" button
  - Clear visual indication of today's completion status
  - Appropriate touch target size

### Swipe Actions
#### Left Swipe
- **Reset Streak**
  - Red background
  - Confirmation dialog required
  - Clear warning about data loss
- **Reset Record**
  - Red background
  - Confirmation dialog required

#### Right Swipe
- **Edit Goal**
  - Opens SetGoalView
  - Pre-populated with current goal settings
- **Override Streak**
  - Date picker for setting start date
  - Updates streak count automatically

## Empty State Component
- Centered in main view area
- Message: "No habits yet. Tap '+' to get started."
- Appropriate spacing and typography
- Optional illustration or icon

## Visual Design
- Consistent spacing between rows
- Clear visual hierarchy
- Minimal visual clutter
- Appropriate contrast for accessibility
- Touch targets meeting iOS guidelines (44pt minimum) 