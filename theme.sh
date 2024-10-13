#!/bin/bash

set -e
shopt -s globstar

mydir="$(dirname "$(realpath "$0")")"
automatic_commit="$1"

pushd "$mydir/matrix-react-sdk" > /dev/null

if [[ "$automatic_commit" == [Yy]* ]]; then
    # Require clean git state
    uncommitted=`git status --porcelain`
    if [ ! -z "$uncommitted" ]; then
        echo "Uncommitted changes are present, please commit first!"
        exit 1
    fi
fi

M_ACCENT="#8bc34a"
M_ACCENT_DEC="139, 195, 74"
M_ACCENT_DARK="#33691e"
M_ACCENT_LIGHT="#dcedc8"
M_ALERT="#e53935"
M_LINK="#368bd6"

replace_colors() {
    local f="$1"
    if [[ "$f" =~ "dark" ]]; then
        echo "Replacing colors (dark) for $f..."
        BG_ACCENT="$M_ACCENT_DARK"
        CODEBLOCK_BORDER_COLOR="#121212"
        CODEBLOCK_BACKGROUND_COLOR="#121212"
        PILL_COLOR="rgba(255, 255, 255, 0.15)"
        PILL_HOVER_COLOR="rgba(255, 255, 255, 0.18)"
        PRESENCE_OFFLINE="#e0e0e0" # not applied because not existing specifically for dark
        MESSAGE_BUBBLE_BACKGROUND="#424242"
        MESSAGE_BUBBLE_BACKGROUND_SELF="#303030"
        MESSAGE_BUBBLE_BACKGROUND_SELECTED="#3f4931"
        ROOMLIST_BG_COLOR="#303030"
        SPACELIST_BG_COLOR="#424242"
    else
        echo "Replacing colors (light) for $f..."
        BG_ACCENT="$M_ACCENT_LIGHT"
        CODEBLOCK_BORDER_COLOR="#00000010"
        CODEBLOCK_BACKGROUND_COLOR="#00000010"
        PILL_COLOR="rgba(0, 0, 0, 0.13)"
        PILL_HOVER_COLOR="rgba(0, 0, 0, 0.1)"
        PRESENCE_OFFLINE="#bdbdbd" # for light this should actually be darker
        MESSAGE_BUBBLE_BACKGROUND="#eeeeee"
        MESSAGE_BUBBLE_BACKGROUND_SELF="#f1f8e9"
        MESSAGE_BUBBLE_BACKGROUND_SELECTED="#dbedc6"
        ROOMLIST_BG_COLOR="#eeeeee"
        SPACELIST_BG_COLOR="#fafafa"
    fi
    # Neutral colors
    sed -i 's|#15171b|#212121|gi' "$f"
    sed -i 's|#15191E|#212121|gi' "$f"
    sed -i 's|#2e2f32|#212121|gi' "$f"
    sed -i 's|#232f32|#212121|gi' "$f"
    sed -i 's|#27303a|#212121|gi' "$f"
    sed -i 's|#17191C|#212121|gi' "$f"
    sed -i 's|#181b21|#303030|gi' "$f"
    sed -i 's|#1A1D23|#303030|gi' "$f"
    sed -i 's|#20252B|#303030|gi' "$f"
    sed -i 's|#20252c|#303030|gi' "$f"
    sed -i 's|#21262c|#383838|gi' "$f" # selection/hover color
    sed -i 's|#238cf5|#303030|gi' "$f"
    sed -i 's|#25271F|#303030|gi' "$f"
    sed -i 's|#272c35|#303030|gi' "$f"
    sed -i 's|#2a3039|#303030|gi' "$f"
    sed -i 's|#343a46|#424242|gi' "$f"
    sed -i 's|#3c4556|#424242|gi' "$f"
    sed -i 's|#3d3b39|#424242|gi' "$f"
    sed -i 's|#45474a|#424242|gi' "$f"
    sed -i 's|#454545|#424242|gi' "$f"
    sed -i 's|#2e3649|#424242|gi' "$f"
    sed -i 's|#4e5054|#424242|gi' "$f"
    sed -i 's|#394049|#424242|gi' "$f"
    sed -i 's|#3e444c|#424242|gi' "$f"
    sed -i 's|#61708b|#616161|gi' "$f"
    sed -i 's|#616b7f|#616161|gi' "$f"
    sed -i 's|#5c6470|#616161|gi' "$f"
    sed -i 's|#545a66|#616161|gi' "$f" # pill hover bg color
    sed -i 's|#737D8C|#757575|gi' "$f"
    sed -i 's|#6F7882|#757575|gi' "$f"
    sed -i 's|#91A1C0|#757575|gi' "$f" # icon in button color
    sed -i 's|#8D99A5|#808080|gi' "$f"
    sed -i 's|#8E99A4|#808080|gi' "$f" # maybe use #9e9e9e instead
    sed -i 's|#8D97A5|#808080|gi' "$f"
    sed -i 's|#a2a2a2|#9e9e9e|gi' "$f"
    sed -i 's|#9fa9ba|#aaaaaa|gi' "$f" # maybe use #9e9e9e instead
    sed -i 's|#acacac|#aaaaaa|gi' "$f" # maybe use #9e9e9e instead
    sed -i 's|#B9BEC6|#b3b3b3|gi' "$f" # maybe use #bdbdbd instead
    sed -i 's|#a1b2d1|#b3b3b3|gi' "$f"
    sed -i 's|#A9B2BC|#b3b3b3|gi' "$f"
    sed -i 's|#C1C6CD|#bdbdbd|gi' "$f"
    sed -i 's|#c1c9d6|#bdbdbd|gi' "$f"
    sed -i 's|#c8c8cd|#cccccc|gi' "$f" # maybe use #bdbdbd instead
    # sed -i 's|#dddddd|#e0e0e0|gi' "$f" # really?
    sed -i 's|#e7e7e7|#e0e0e0|gi' "$f"
    sed -i 's|#e3e8f0|#e0e0e0|gi' "$f"
    sed -i 's|#e9e9e9|#e0e0e0|gi' "$f"
    sed -i 's|#e9edf1|#e0e0e0|gi' "$f"
    sed -i 's|#e8eef5|#e0e0e0|gi' "$f"
    sed -i 's|#deddfd|#e0e0e0|gi' "$f" # $location-live-secondary-color, what to use really?
    sed -i 's|#edf3ff|#eeeeee|gi' "$f"
    sed -i 's|#f4f6fa|#f5f5f5|gi' "$f"
    sed -i 's|#f6f7f8|#f5f5f5|gi' "$f"
    sed -i 's|#f2f5f8|#f5f5f5|gi' "$f"
    sed -i 's|#f5f8fa|#f5f5f5|gi' "$f"
    sed -i 's|#f3f8fd|#fafafa|gi' "$f"
    sed -i 's|rgba(33, 38, 34,|rgba(48, 48, 48,|gi' "$f"
    sed -i 's|rgba(33, 38, 44,|rgba(48, 48, 48,|gi' "$f"
    sed -i 's|rgba(34, 38, 46,|rgba(48, 48, 48,|gi' "$f"
    sed -i 's|rgba(38, 39, 43,|rgba(48, 48, 48,|gi' "$f"
    sed -i 's|rgba(38, 40, 45,|rgba(48, 48, 48,|gi' "$f"
    sed -i 's|rgba(46, 48, 51,|rgba(48, 48, 48,|gi' "$f"
    sed -i 's|rgba(92, 100, 112,|rgba(97, 97, 97,|gi' "$f"
    sed -i 's|rgba(141, 151, 165,|rgba(144, 144, 144,|gi' "$f"
    sed -i 's|rgba(242, 245, 248,|rgba(248, 248, 248,|gi' "$f"

    sed -i "s|\\(\$event-highlight-bg-color: \\).*;|\\1transparent;|gi" "$f"
    sed -i "s|\\(\$preview-widget-bar-color: \\).*;|\\1#bdbdbd;|gi" "$f"
    sed -i "s|\\(\$blockquote-bar-color: \\).*;|\\1#bdbdbd;|gi" "$f"
    sed -i "s|\\(\$pill-bg-color: \\).*;|\\1$PILL_COLOR;|gi" "$f"
    sed -i "s|\\(\$pill-hover-bg-color: \\).*;|\\1$PILL_HOVER_COLOR;|gi" "$f"

    sed -i "s|\\(\$inlinecode-border-color: \\).*;|\\1$CODEBLOCK_BORDER_COLOR;|gi" "$f"
    sed -i "s|\\(\$inlinecode-background-color: \\).*;|\\1$CODEBLOCK_BACKGROUND_COLOR;|gi" "$f"
    sed -i "s|\\(\$codeblock-background-color: \\).*;|\\1$CODEBLOCK_BACKGROUND_COLOR;|gi" "$f"

    sed -i "s|\\(\$presence-offline: \\).*;|\\1$PRESENCE_OFFLINE;|gi" "$f"

    sed -i "s|\\(\$roomlist-bg-color: \\).*;|\\1$ROOMLIST_BG_COLOR;|gi" "$f"
    sed -i "s|\\(\$spacePanel-bg-color: \\).*;|\\1$SPACELIST_BG_COLOR;|gi" "$f"

    # Accent colors
    sed -i "s|#368bd6|$M_ACCENT|gi" "$f"
    sed -i "s|#ac3ba8|$M_ACCENT|gi" "$f"
    sed -i "s|#0DBD8B|$M_ACCENT|gi" "$f"
    sed -i "s|#e64f7a|$M_ACCENT|gi" "$f"
    sed -i "s|#ff812d|$M_ACCENT|gi" "$f"
    sed -i "s|#2dc2c5|$M_ACCENT|gi" "$f"
    sed -i "s|#5c56f5|$M_ACCENT|gi" "$f"
    sed -i "s|#74d12c|$M_ACCENT|gi" "$f"
    sed -i "s|#76CFA6|$M_ACCENT|gi" "$f"
    sed -i "s|#03b381|$M_ACCENT|gi" "$f"
    sed -i "s|rgba(3, 179, 129,|rgba($M_ACCENT_DEC,|gi" "$f"
    sed -i "s|#03b381|$M_ACCENT|gi" "$f"
    sed -i "s|#FF5B55|$M_ALERT|gi" "$f"
    sed -i "s|\\(\$accent-alt: \\).*;|\\1$M_LINK;|gi" "$f"
    #sed -i "s|\\(\$accent-darker: \\).*;|\\1$M_ACCENT_DARK;|gi" "$f"
    sed -i "s|\\(\$roomtile-default-badge-bg-color: \\).*;|\\1$M_ACCENT;|gi" "$f"
    #sed -i "s|\\(\$input-focused-border-color: \\).*;|\\1\$accent;|gi" "$f" # not existing anymore, need replacement?
    sed -i "s|\\(\$reaction-row-button-selected-bg-color: \\).*;|\\1$BG_ACCENT;|gi" "$f"

    # e2e colors
    sed -i "s|\\(\$e2e-verified-color: \\).*;|\\1$M_ACCENT;|gi" "$f"
    sed -i "s|\\(\$e2e-unknown-color: \\).*;|\\1#ffc107;|gi" "$f"
    sed -i "s|\\(\$e2e-unverified-color: \\).*;|\\1#ffc107;|gi" "$f"
    sed -i "s|\\(\$e2e-warning-color: \\).*;|\\1$M_ALERT;|gi" "$f"

    # Message bubbles
    sed -i "s|\\(\$eventbubble-self-bg: \\).*;|\$eventbubble-self-bg: $MESSAGE_BUBBLE_BACKGROUND_SELF;|gi" "$f"
    sed -i "s|\\(\$eventbubble-others-bg: \\).*;|\$eventbubble-others-bg: $MESSAGE_BUBBLE_BACKGROUND;|gi" "$f"
    sed -i "s|\\(\$eventbubble-bg-hover: \\).*;|\$eventbubble-bg-hover: $MESSAGE_BUBBLE_BACKGROUND_SELECTED;|gi" "$f"
    #sed -i "s|\\(\$eventbubble-reply-color: \\).*;$||gi" "$f"
}

replace_colors res/themes/light/css/light.pcss
replace_colors res/themes/light/css/_light.pcss
replace_colors res/themes/legacy-light/css/legacy-light.pcss
replace_colors res/themes/legacy-light/css/_legacy-light.pcss
replace_colors res/themes/dark/css/dark.pcss
replace_colors res/themes/dark/css/_dark.pcss
replace_colors res/themes/legacy-dark/css/legacy-dark.pcss
replace_colors res/themes/legacy-dark/css/_legacy-dark.pcss
for f in res/**/*.svg; do
    replace_colors "$f"
done

if [[ "$automatic_commit" == [Yy]* ]]; then
    # see: https://devops.stackexchange.com/a/5443
    git add -A
    git diff-index --quiet HEAD || git commit -m "Automatic theme update"
fi

popd > /dev/null
