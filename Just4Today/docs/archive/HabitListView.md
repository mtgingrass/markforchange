## Purpose
This is the screen where users see all of their tracked habits. The purpose of this screen is to display each habit’s current streak, status, and allow quick interactions such as resetting progress or editing the goal. The screen should feel smooth, minimal, and dynamic — with intuitive swipe gestures and animation.

## UI Elements for HabitListView

### Overall Look
- A vertically scrollable list of habits
- Clean and readable spacing between items
- Minimal visual clutter — each row gets to the point

### Top Bar
- **Title**: “Your Habits”
- Optional buttons in the top right:
  - **+ Add Habit**
  - **Global Settings**

### Habit Row Layout
Each row represents one habit and includes:
- **Habit Title** (e.g., “Gym”, “Read 10 pages”)
- **Streak Display**: Show current streak and all-time record
  - Example: “Streak: 4 🔥  • Record: 12”
- **Completion Status**:
  - Checkbox or “Mark Done” button
  - If already completed today, show as completed
- **Swipe Actions**:
  - Swipe Left:
    - Reset Streak (confirmation dialog required)
    - Reset Record (confirmation dialog required)
  - Swipe Right:
    - Edit Goal → Opens `SetGoalView`
    - Override Streak ("Don't cheat"). The idea is that you may already have a 100 day streak with something (eg. quit drinking 100 days ago). This would allow a user to set that start streak. This could pop up a date picker instead of a number. 

### Empty State
- If no habits exist, display a friendly message:
  > “No habits yet. Tap '+' to get started.”

## Functionality & Logic

- **Smooth List Scrolling**: Avoid visual lag or jumping
- **Swipe Gestures**:
  - Left =  reset actions
  - Right = Edit Goal or Override streak. 
- **Streak Logic**:
  - Streak increments if marked as complete for today
  - If not marked by end of day, streak breaks and is set back to day 0.
  - Record updates automatically if streak is broken
- **Dynamic Layout**:
  - If a habit is marked “Just for Today” or “Lenient Tracking”, the UI may visually flag that
  - Display logic should reflect current goal configuration
- Tap on Habit
	- This shoudl bring up a screen to rename the habit, and view some cool statistics. 

## Design Goals

- Uses reusable row view component: `HabitRowView`
- Built using MVVM with clear separation of logic
- Touch targets should be large enough for accessibility
- Animations for swipe actions, row insert/delete
- Smooth gesture transitions with haptic feedback (if possible)

## Example Use Cases

**User checks in a habit**
- User taps “Mark Done” next to “Drink Water”
- Streak increases, row updates visually to reflect completion

**User wants to reset a streak**
- Swipes left on “Workout”
- Taps “Reset Streak” → Confirmation popup appears
- If confirmed, streak resets to 0

**User wants to update their goal**
- Swipes right on “Meditation”
- Taps “Edit Goal” → Navigates to `SetGoalView` preloaded with habit data

## Future Enhancements
These are not to be built yet, but should be considered in the app structure:
- Drag-and-drop to reorder habits