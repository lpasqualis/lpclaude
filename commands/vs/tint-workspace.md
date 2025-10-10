---
name: /vs:tint-workspace
description: Apply a subtle color tint to VS Code workspace for visual differentiation
allowed-tools:
  - Read
  - Write
  - Edit
  - LS
  - Glob
disable-model-invocation: true
---

# VS Code Workspace Tinter

Apply a subtle color tint to your VS Code workspace to visually differentiate it from other open workspaces. This command modifies the workspace's color theme with a gentle overlay that maintains readability while providing clear visual distinction.

## Usage

### Basic Color Tints
Specify a standard color to apply as a tint:
- `/vs:tint-workspace purple` - Apply a purple tint
- `/vs:tint-workspace blue` - Apply a blue tint  
- `/vs:tint-workspace green` - Apply a green tint
- `/vs:tint-workspace orange` - Apply an orange tint
- `/vs:tint-workspace red` - Apply a red tint
- `/vs:tint-workspace cyan` - Apply a cyan tint
- `/vs:tint-workspace yellow` - Apply a yellow tint
- `/vs:tint-workspace pink` - Apply a pink tint
- `/vs:tint-workspace teal` - Apply a teal tint
- `/vs:tint-workspace indigo` - Apply an indigo tint

### Adjustments and Variations
Make relative adjustments to the current theme:
- `/vs:tint-workspace slightly darker` - Darken the current colors by 10%
- `/vs:tint-workspace much darker` - Darken the current colors by 25%
- `/vs:tint-workspace slightly lighter` - Lighten the current colors by 10%
- `/vs:tint-workspace more saturated` - Increase color saturation
- `/vs:tint-workspace less saturated` - Decrease saturation (more muted)
- `/vs:tint-workspace warmer` - Shift colors toward warm tones
- `/vs:tint-workspace cooler` - Shift colors toward cool tones

### Creative and Thematic Requests
Describe the aesthetic you want:
- `/vs:tint-workspace like a 1980s P1 phosphor green screen` - Retro amber/green terminal
- `/vs:tint-workspace cyberpunk neon` - High contrast neon colors
- `/vs:tint-workspace forest theme` - Natural greens and browns
- `/vs:tint-workspace ocean depths` - Deep blues and teals
- `/vs:tint-workspace sunset` - Warm oranges and purples
- `/vs:tint-workspace like a old IBM terminal` - Classic blue and white
- `/vs:tint-workspace Matrix style` - Green text on black
- `/vs:tint-workspace minimal with a hint of [color]` - Very subtle tinting

### Custom Descriptions
You can describe any color scheme you want:
- `/vs:tint-workspace professional but with personality`
- `/vs:tint-workspace dark but not too dark with purple accents`
- `/vs:tint-workspace like GitHub's dark theme but warmer`

## Implementation

1. First, find the workspace file in the current directory
2. **Parse and interpret the user's request**:
   - Standard color names (purple, blue, etc.)
   - Relative adjustments (darker, lighter, warmer, etc.)
   - Creative descriptions (retro terminal, cyberpunk, etc.)
   - Custom requests using natural language
3. **Detect the current VS Code theme type** (dark/light) from settings or infer from existing customizations
4. **Generate appropriate color scheme** based on request type:
   - For standard colors: Apply tint overlay
   - For adjustments: Modify existing colors
   - For creative themes: Generate complete custom schemes
   - For descriptions: Interpret intent and create matching colors
5. Apply the color customizations to key VS Code UI elements
6. Save the changes to the workspace file

## Smart Tinting Algorithm

The command should:
- **Preserve theme brightness**: Dark themes stay dark, light themes stay light
- **Apply tint as overlay**: Blend the requested color with existing colors using color mixing
- **Maintain contrast ratios**: Ensure text remains readable
- **Adapt to base theme**: Different behavior for dark vs light themes

### For Dark Themes
- Apply tint to darker backgrounds (10-20% tint saturation)
- Keep foregrounds light with subtle tint influence
- Maintain dark aesthetic while adding color identity

### For Light Themes  
- Apply tint to lighter backgrounds (5-10% tint saturation)
- Keep foregrounds dark with minimal tint
- Maintain bright aesthetic while adding subtle color

## Color Scheme Design Principles

- **Theme-Aware**: Detect and respect the base theme (dark/light)
- **True Tinting**: Apply color as an overlay, not a replacement
- **Subtle Application**: 10-20% tint strength for dark themes, 5-10% for light themes
- **Maintain Readability**: Preserve contrast ratios from the base theme
- **Visual Hierarchy**: Keep relative brightness relationships intact

## Request Interpretation Guide

### Standard Color Tints
Base tint colors (to be blended with existing theme):
- **Purple**: RGB(128, 0, 128) - #800080
- **Blue**: RGB(0, 100, 200) - #0064C8  
- **Green**: RGB(0, 150, 0) - #009600
- **Orange**: RGB(255, 140, 0) - #FF8C00
- **Red**: RGB(200, 0, 0) - #C80000
- **Cyan**: RGB(0, 150, 150) - #009696
- **Yellow**: RGB(200, 200, 0) - #C8C800
- **Pink**: RGB(255, 105, 180) - #FF69B4
- **Teal**: RGB(0, 128, 128) - #008080
- **Indigo**: RGB(75, 0, 130) - #4B0082

### Relative Adjustments
Apply these transformations to existing colors:
- **"darker"/"lighter"**: Adjust brightness by specified amount
- **"warmer"**: Shift hue toward red/orange spectrum
- **"cooler"**: Shift hue toward blue/green spectrum
- **"more/less saturated"**: Adjust color intensity
- **"muted"**: Reduce saturation significantly
- **"vibrant"**: Increase saturation and slight brightness

### Creative Themes
Complete color schemes for specific aesthetics:

**Retro Terminal Themes:**
- **P1 Phosphor Green**: Green (#00FF00) on black with amber highlights
- **P3 Phosphor Amber**: Amber (#FFAA00) on dark brown
- **IBM 3270**: Green (#00FF00) on black, classic terminal
- **VT100**: White on black with green accents
- **Matrix**: Bright green (#00FF00) cascading on black

**Aesthetic Themes:**
- **Cyberpunk**: Neon pink/cyan on dark purple/black
- **Forest**: Deep greens, browns, with moss accents
- **Ocean**: Deep blues, teals, with aqua highlights
- **Sunset**: Gradient of oranges, pinks, purples
- **Midnight**: Very dark blues with silver accents
- **Pastel**: Soft, light colors with low saturation

### Natural Language Processing
When receiving descriptive requests:
1. Identify key color words (purple, blue, warm, dark)
2. Identify intensity modifiers (slightly, very, extremely)
3. Identify style references (retro, modern, minimal)
4. Combine elements to create appropriate scheme

## Tinting Process

1. **Detect Theme Type**:
   - Check if existing customizations suggest dark theme (dark backgrounds)
   - Check if existing customizations suggest light theme (light backgrounds)
   - Default to dark if no customizations exist

2. **Apply Tint Using Color Blending**:
   ```
   For dark themes:
   - New Color = (Base Color × 0.85) + (Tint Color × 0.15)
   
   For light themes:
   - New Color = (Base Color × 0.92) + (Tint Color × 0.08)
   ```

3. **Generate Default Base Colors** if no customizations exist:
   
   For dark theme defaults:
   - activityBar.background: #1e1e1e
   - statusBar.background: #007ACC
   - sideBar.background: #252526
   - titleBar.activeBackground: #1e1e1e
   
   For light theme defaults:
   - activityBar.background: #f3f3f3
   - statusBar.background: #007ACC  
   - sideBar.background: #f8f8f8
   - titleBar.activeBackground: #f3f3f3

## Workspace File Structure

Update or create a `.code-workspace` file with this structure:

```json
{
  "folders": [
    {
      "path": "."
    }
  ],
  "settings": {
    "workbench.colorCustomizations": {
      // Activity Bar
      "activityBar.background": "[base-color]",
      "activityBar.foreground": "[foreground-color]",
      "activityBar.border": "[border-color]",
      "activityBarBadge.background": "[accent-color]",
      "activityBarBadge.foreground": "#ffffff",
      
      // Status Bar
      "statusBar.background": "[medium-color]",
      "statusBar.foreground": "[foreground-color]",
      "statusBar.border": "[border-color]",
      "statusBarItem.activeBackground": "[accent-color]",
      
      // Title Bar
      "titleBar.activeBackground": "[base-color]",
      "titleBar.activeForeground": "[foreground-color]",
      "titleBar.inactiveBackground": "[darker-variant]",
      "titleBar.inactiveForeground": "[dimmed-foreground]",
      
      // Sidebar
      "sideBar.background": "[dark-color]",
      "sideBar.foreground": "[foreground-color]",
      "sideBar.border": "[border-color]",
      "sideBarSectionHeader.background": "[medium-color]",
      
      // Tabs
      "tab.activeBackground": "[base-color]",
      "tab.activeForeground": "[foreground-color]",
      "tab.inactiveBackground": "[dark-color]",
      "tab.inactiveForeground": "[dimmed-foreground]",
      "tab.border": "[border-color]",
      
      // Lists and Trees
      "list.activeSelectionBackground": "[medium-color]",
      "list.activeSelectionForeground": "[foreground-color]",
      "list.hoverBackground": "[hover-color]",
      "list.focusBackground": "[focus-color]",
      
      // Panel
      "panel.background": "[dark-color]",
      "panel.border": "[border-color]",
      "panelTitle.activeForeground": "[foreground-color]",
      
      // Terminal
      "terminal.background": "[darkest-variant]",
      "terminal.foreground": "[terminal-foreground]",
      "terminal.border": "[border-color]",
      
      // Editor Groups (optional)
      "editorGroupHeader.tabsBackground": "[dark-color]",
      
      // Breadcrumb (optional)
      "breadcrumb.background": "[dark-color]",
      "breadcrumb.foreground": "[dimmed-foreground]"
    }
  }
}
```

## Steps

1. Check if a `.code-workspace` file exists in the current directory
2. If not, look for any `*.code-workspace` file  
3. If no workspace file exists, create one with the default name `workspace.code-workspace`
4. **Interpret the user's request**:
   - Check for standard color names
   - Look for relative adjustment keywords (darker, warmer, etc.)
   - Identify creative theme requests (retro, cyberpunk, etc.)
   - Parse natural language descriptions
5. **Read existing color customizations** from the workspace file (if any)
6. **Detect theme type** by analyzing existing colors or using defaults
7. **Generate colors based on request type**:
   - Standard tints: Blend with existing colors
   - Adjustments: Transform current colors
   - Creative themes: Apply complete preset
   - Descriptions: Interpret and generate custom scheme
8. Update the workspace file with the new color customizations
9. Inform the user about the changes and suggest reload if needed

## Important Notes

- **Flexible interpretation**: The command understands natural language and creative descriptions
- **Iterative refinement**: Keep running the command with adjustments until you get the perfect look
- **Theme-aware**: Respects your base theme when applying standard tints
- **Creative freedom**: Request any aesthetic you can describe
- **Professional defaults**: Standard tints are subtle and workplace-appropriate
- **Instant preview**: Changes apply immediately after VS Code reload (Cmd/Ctrl+R)

## Examples of Complex Requests

The command can handle sophisticated requests like:
- "Make it look like the terminal from Blade Runner"
- "I want it 20% darker with a slight blue tint"
- "Give me that VS Code look but make it feel more like IntelliJ"
- "Subtle earth tones, like working in a coffee shop"
- "High contrast but easy on the eyes for late night coding"
- "Like Dracula theme but warmer and less purple"