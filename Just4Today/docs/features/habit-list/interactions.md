# Interactions - HabitListView

## Gesture Interactions

### Swipe Gestures
- **Left Swipe**
  - Smooth animation revealing reset actions
  - Haptic feedback on full reveal
  - Returns to original position on release
  - Requires full swipe for action activation

- **Right Swipe**
  - Smooth animation revealing edit actions
  - Haptic feedback on full reveal
  - Returns to original position on release
  - Requires full swipe for action activation

### Tap Interactions
- **Habit Row Tap**
  - Opens detailed statistics view
  - Shows habit renaming option
  - Displays additional metrics

- **Completion Marking**
  - Tap to mark complete
  - Visual feedback animation
  - Updates streak immediately
  - Haptic feedback on completion

## Confirmation Dialogs

### Reset Streak Dialog
- **Title**: "Reset Streak?"
- **Message**: Clear warning about losing progress
- **Actions**:
  - "Cancel" (primary)
  - "Reset" (destructive)
- Haptic warning feedback

### Reset Record Dialog
- **Title**: "Reset Record?"
- **Message**: Warning about losing all-time best
- **Actions**:
  - "Cancel" (primary)
  - "Reset" (destructive)
- Haptic warning feedback

## Animation Specifications

### Row Animations
- Smooth insert/delete transitions
- Natural spring animations for swipes
- Completion state transitions
- Streak update animations

### Feedback
- Haptic feedback levels:
  - Light: General interactions
  - Medium: Important actions
  - Heavy: Destructive actions
- Visual feedback for all interactions
- Clear success/failure states 