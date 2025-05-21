
## Purpose
Allow the user to configure a flexible and motivating goal for a given habit. The focus is on weekly cadence or a "Just for Today" goals, and customization options such as leniency. The following is just for the SetGoalView (when the user clicks on Set Goal in the UI)

## UI Elements for SetGoalView

### Overall Look
![[HIdden/Pasted image 20250519122405.png]]
### Top Bar
- **Title**: "Set Goal" (Note that the graphic shows "Set Weekly Goal", but I want it to just say "Set Goal")
	- Make it aesthetically pleasing. 
- **Close Button (X)**: Top-right corner. Closes the modal/sheet.
- Subtitle - "Choose Goal Type" - make it all CAPS.

### Choose Goal Type
- **Toggle**: "Just for Today" — Enables a one-time goal for the current day only.
  OR
 "Select days to complete this habit":

### Select Days of the Week
- Horizontal or vertical list of buttons that when selected, will toggle showing that it's been selected. The ability to deselect needs to be there, too:
  - `Sunday`, `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday` (Or any variation of abbreviations that may help it fit on the screen better)
- User can select/deselect any combination of days.

### Lenient Tracking
- **Toggle**: Enable or disable lenient tracking.
- **Info Box** (tapable/expandable):
  - **Label**: "What is lenient tracking?"
  - **Explanation**:  
    > With lenient tracking, it doesn't matter which days you do the habit.  
    > As long as you complete it the desired number of times in a week,  
    > it is counted as successful. You can choose the days of week for your own tracking, but the count is what matters with lenient tracking enabled. 

### Goal Target Type
- User must choose **one** of the following:
  - Weekly Target
  - Total Days Target
  - Forever

### Goal Target Entry
- **Weekly Target Fields**:
  - Number of weeks (e.g., `4`)
- **Total Days Field**:
  - Total completions (e.g., `100`)

### Action Buttons
- **Set Goal** — Confirms and saves the configuration. Then returns to the previous screen.
- **Clear Goal** — Resets all selected options and input fields. Thens tays on the SetGoalView screen. 

## Functionality & Logic

- **Close Button**: Dismisses the view.
- **Just for Today Toggle**: Disables all other input when enabled.
- **Day Selector**: Each day is individually selectable. Used when “Just for Today” is off.
- **Lenient Tracking**: If enabled, the selected days are advisory — any combination of days can be used to fulfill the weekly quota.
- **Mutual Exclusivity**:
  - Weekly target: requires days/week and weeks.
  - Total days target: requires total completions.
  - Cannot choose both at the same time.

## Design Goals

- Smooth scrolling
- Modular, reusable SwiftUI components:
  - `DaySelectorView`
  - `InfoToggleView`
  - `GoalInputSection`
- MVVM architecture
- Minimalist and accessible UI
- Animations for interaction feedback

## Example Use Cases

**Gym Goal (Weekly)**
- User wants to work out 4x/week for 4 weeks
- Selects: Monday, Wednesday, Friday, Sunday
- Lenient tracking: off
- Weekly goal: 4/week for 4 weeks

**Pushup Goal (Total Days)**
- User wants to do 100 pushups, whenever
- Lenient tracking: on
- Total days goal: 100 completions

## Future Enhancements 
All future enhancements are not to be coded for, but be mindful of the code produced so that the enhancements can integrate one day, if I choose to do these. 
- Add hourly goal choices for "Just for Today"
- Calendar sync
