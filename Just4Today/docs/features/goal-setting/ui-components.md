# UI Components - SetGoalView

## Top Bar
- **Title**: "Set Goal"
- **Close Button**: X in top-right corner
- **Subtitle**: "CHOOSE GOAL TYPE" (all caps)

## Goal Type Selection
### Just for Today Toggle
- **Label**: "Just for Today"
- **Description**: One-time goal for current day
- **Behavior**: Disables other options when selected

### Day Selector Component
- **Layout**: Horizontal/vertical list of day buttons
- **Days**: Sun, Mon, Tue, Wed, Thu, Fri, Sat
  - Abbreviations allowed for better fit
- **Button States**:
  - Selected: Clear visual indication
  - Unselected: Default state
  - Disabled: When "Just for Today" is active

## Lenient Tracking Section
### Toggle Component
- **Label**: "Lenient Tracking"
- **States**: On/Off
- **Visual**: Clear indication of current state

### Info Box Component
- **Label**: "What is lenient tracking?"
- **Expandable**: Tappable for more information
- **Content**:
  > With lenient tracking, it doesn't matter which days you do the habit.
  > As long as you complete it the desired number of times in a week,
  > it is counted as successful. You can choose the days of week for your own tracking,
  > but the count is what matters with lenient tracking enabled.

## Goal Target Section
### Target Type Selection
- **Options**:
  - Weekly Target
  - Total Days Target
  - Forever
- **Mutual Exclusivity**: Only one selectable

### Input Fields
- **Weekly Target**:
  - Number of weeks field
  - Numeric keyboard
  - Validation for reasonable values
- **Total Days**:
  - Total completions field
  - Numeric keyboard
  - Validation for reasonable values

## Action Buttons
### Set Goal Button
- **Label**: "Set Goal"
- **Position**: Bottom of view
- **Behavior**: Saves and returns to previous screen
- **State**: Disabled if required fields empty

### Clear Goal Button
- **Label**: "Clear Goal"
- **Position**: Below Set Goal button
- **Behavior**: Resets all fields
- **State**: Always enabled

## Visual Design
- Clean, minimal interface
- Clear hierarchy of options
- Appropriate spacing between sections
- Consistent typography
- iOS standard control sizes
- Accessible touch targets 