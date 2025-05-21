# Goal Types - SetGoalView

## Just for Today
### Description
- Single-day commitment
- Resets at midnight
- No streak tracking
- Simplest form of goal

### Configuration
- Toggle to enable
- Disables other options
- No additional settings required

## Weekly Target
### Description
- Recurring weekly schedule
- Specific days selected
- Streak tracking enabled
- Time-bound commitment

### Configuration
- Number of weeks
- Days of week selection
- Optional lenient tracking
- Progress tracked weekly

### Example
**Gym Workout Plan**
- 4x per week for 4 weeks
- Selected days: Mon, Wed, Fri, Sun
- Lenient tracking: off
- Clear weekly structure

## Total Days Target
### Description
- Cumulative goal tracking
- Flexible completion schedule
- Progress towards total
- No weekly structure required

### Configuration
- Total number of completions
- Optional day preferences
- Typically uses lenient tracking
- No time constraint

### Example
**100 Pushups Challenge**
- Total goal: 100 days
- Any day completion allowed
- Lenient tracking: on
- Flexible scheduling

## Forever
### Description
- Ongoing commitment
- No end date
- Continuous tracking
- Focus on consistency

### Configuration
- Day selection optional
- Lenient tracking optional
- No numerical targets
- Permanent habit formation

## Validation Rules
### Just for Today
- Cannot combine with other types
- No numerical inputs required
- Single day scope

### Weekly Target
- Requires:
  - Number of weeks > 0
  - At least one day selected
  - Valid weekly frequency

### Total Days Target
- Requires:
  - Total days > 0
  - Cannot combine with weekly
  - Valid total number

### Forever
- Optional day selection
- No numerical validation
- Can use lenient tracking 