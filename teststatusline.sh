#!/usr/bin/env bash

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATUSLINE_DIR="$SCRIPT_DIR/statusline"

# Function to test a statusline with multiple variations
test_statusline() {
    local script="$1"
    local script_name=$(basename "$script")
    
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Testing: ${YELLOW}$script_name${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
    
    # Test case 1: Default (small context, minimal changes)
    echo -e "${MAGENTA}1. Default (small context, minimal changes):${NC}"
    echo '{"model":{"display_name":"Opus 4.1"},"output_style":{"name":"Claude Agentic Framework"},"workspace":{"current_dir":"/Users/lpasqualis/.lpclaude"},"exceeds_200k_tokens":false,"cost":{"total_lines_added":12,"total_lines_removed":3}}' | "$script"
    echo ""
    
    # Test case 2: Large context warning
    echo -e "${MAGENTA}2. Large context (>200k tokens):${NC}"
    echo '{"model":{"display_name":"Opus 4.1"},"output_style":{"name":"Claude Agentic Framework"},"workspace":{"current_dir":"/Users/lpasqualis/.lpclaude"},"exceeds_200k_tokens":true,"cost":{"total_lines_added":500,"total_lines_removed":250}}' | "$script"
    echo ""
    
    # Test case 3: No changes
    echo -e "${MAGENTA}3. No code changes:${NC}"
    echo '{"model":{"display_name":"Opus 4.1"},"output_style":{"name":"Default"},"workspace":{"current_dir":"/Users/lpasqualis/projects"},"exceeds_200k_tokens":false,"cost":{"total_lines_added":0,"total_lines_removed":0}}' | "$script"
    echo ""
    
    # Test case 4: Large refactoring
    echo -e "${MAGENTA}4. Large refactoring (many changes):${NC}"
    echo '{"model":{"display_name":"Claude 3.5"},"output_style":{"name":"Code Review"},"workspace":{"current_dir":"/Users/lpasqualis/bigproject"},"exceeds_200k_tokens":false,"cost":{"total_lines_added":1523,"total_lines_removed":892}}' | "$script"
    echo ""
    
    # Test case 5: Different model and style
    echo -e "${MAGENTA}5. Different model and output style:${NC}"
    echo '{"model":{"display_name":"Haiku"},"output_style":{"name":"Concise"},"workspace":{"current_dir":"/tmp/test"},"exceeds_200k_tokens":false,"cost":{"total_lines_added":42,"total_lines_removed":17}}' | "$script"
    echo ""
    
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    # echo ""
    # echo -n -e "${GREEN}Press Enter to continue...${NC}"
    # read -r
}

# Function to list and select statusline
select_statusline() {
    while true; do
        # clear
        echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║     Statusline Testing Utility           ║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}Available statusline scripts:${NC}"
        echo ""
        
        # Find all .sh files in statusline directory
        local scripts=()
        local i=1
        
        for script in "$STATUSLINE_DIR"/*.sh; do
            if [[ -f "$script" ]]; then
                local basename=$(basename "$script")
                scripts+=("$script")
                echo -e "  ${YELLOW}$i)${NC} $basename"
                ((i++))
            fi
        done
        
        if [[ ${#scripts[@]} -eq 0 ]]; then
            echo -e "${RED}No statusline scripts found in $STATUSLINE_DIR${NC}"
            exit 1
        fi
        
        echo -e "  ${YELLOW}q)${NC} Quit"
        echo ""
        echo -e "${GREEN}Options:${NC}"
        echo -e "  - Enter ${YELLOW}1-${#scripts[@]}${NC} to test a statusline"
        echo -e "  - Enter ${YELLOW}a1-a${#scripts[@]}${NC} to activate a statusline"
        echo -e "  - Enter ${YELLOW}q${NC} to quit"
        echo ""
        echo -n -e "${GREEN}Your choice: ${NC}"
        read -r choice
        
        # Check for quit
        if [[ "$choice" == "q" ]] || [[ "$choice" == "Q" ]]; then
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
        fi
        
        # Check for activation (a1, a2, etc.)
        if [[ "$choice" =~ ^[aA]([0-9]+)$ ]]; then
            local num="${BASH_REMATCH[1]}"
            if [[ "$num" -lt 1 ]] || [[ "$num" -gt ${#scripts[@]} ]]; then
                echo -e "${RED}Invalid selection. Press Enter to try again...${NC}"
                read -r
                continue
            fi
            
            # Get selected script
            local selected="${scripts[$((num-1))]}"
            local script_name=$(basename "$selected")
            
            # Backup current statusline.sh if it exists and is not a symlink
            if [[ -f "$STATUSLINE_DIR/statusline.sh" ]] && [[ ! -L "$STATUSLINE_DIR/statusline.sh" ]]; then
                cp "$STATUSLINE_DIR/statusline.sh" "$STATUSLINE_DIR/statusline.sh.backup"
                echo -e "${CYAN}Backed up current statusline.sh to statusline.sh.backup${NC}"
            fi
            
            # Copy the selected statusline to statusline.sh
            cp "$selected" "$STATUSLINE_DIR/statusline.sh"
            echo ""
            echo -e "${GREEN}✓ Activated: ${YELLOW}$script_name${GREEN} → statusline.sh${NC}"
            echo ""
            
            # Show a quick test of the activated statusline
            echo -e "${CYAN}Quick test of activated statusline:${NC}"
            echo '{"model":{"display_name":"Opus 4.1"},"output_style":{"name":"Claude Agentic Framework"},"workspace":{"current_dir":"/Users/lpasqualis/.lpclaude"},"exceeds_200k_tokens":false,"cost":{"total_lines_added":12,"total_lines_removed":3}}' | "$STATUSLINE_DIR/statusline.sh"
            echo ""
            echo ""
            echo -n -e "${GREEN}Press Enter to continue...${NC}"
            read -r
            continue
        fi
        
        # Regular test selection (1, 2, etc.)
        if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]] || [[ "$choice" -gt ${#scripts[@]} ]]; then
            echo -e "${RED}Invalid selection. Press Enter to try again...${NC}"
            read -r
            continue
        fi
        
        # Get selected script and test it
        local selected="${scripts[$((choice-1))]}"
        # clear
        test_statusline "$selected"
    done
}

# Main execution
select_statusline