source common.sh

clearStore
clearCache

# No packages
(( $(NIX_PATH= nix search -u|wc -l) == 0 ))

# Haven't updated cache, still nothing
(( $(nix search -f search.nix hello|wc -l) == 0 ))
(( $(nix search -f search.nix |wc -l) == 0 ))

# Update cache, search should work
(( $(nix search -f search.nix -u hello|wc -l) > 0 ))

# Use cache
(( $(nix search -f search.nix foo|wc -l) > 0 ))
(( $(nix search foo|wc -l) > 0 ))

# Test --no-cache works
# No results from cache
(( $(nix search --no-cache foo |wc -l) == 0 ))
# Does find results from file pointed at
(( $(nix search -f search.nix --no-cache foo |wc -l) > 0 ))

# Check descriptions are searched
(( $(nix search broken | wc -l) > 0 ))

# Check search that matches nothing
(( $(nix search nosuchpackageexists | wc -l) == 0 ))


## Search expressions

# Check that empty search string matches all
EMPTY=$(nix search)
BOL=$(nix search "^")
ALL=$(nix search ".*")

diff <(printf "%s" $EMPTY) <(printf "%s" $BOL)
# "ALL" highlights differently, not sure preferred behavior
# diff <(printf "%s" $EMPTY) <(printf "%s" $ALL)
