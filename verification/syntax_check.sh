#!/bin/bash

# Syntax verification for Dart files
# Checks for common syntax errors without requiring Flutter/Dart SDK

echo "============================================================"
echo "VIB34D Flutter SDK - Syntax Verification"
echo "============================================================"
echo

# Find all Dart files
DART_FILES=$(find lib test example/lib -name "*.dart" 2>/dev/null | sort)

if [ -z "$DART_FILES" ]; then
    echo "❌ No Dart files found"
    exit 1
fi

TOTAL=0
VALID=0
WARNINGS=0

echo "Checking Dart files for syntax errors..."
echo

for file in $DART_FILES; do
    TOTAL=$((TOTAL + 1))
    ERRORS=0

    # Check for common syntax errors

    # 1. Unclosed braces
    OPEN_BRACES=$(grep -o '{' "$file" | wc -l)
    CLOSE_BRACES=$(grep -o '}' "$file" | wc -l)

    # 2. Unclosed parentheses
    OPEN_PARENS=$(grep -o '(' "$file" | wc -l)
    CLOSE_PARENS=$(grep -o ')' "$file" | wc -l)

    # 3. Unclosed brackets
    OPEN_BRACKETS=$(grep -o '\[' "$file" | wc -l)
    CLOSE_BRACKETS=$(grep -o '\]' "$file" | wc -l)

    # 4. Check for basic Dart syntax patterns
    if ! grep -q "^import " "$file" && ! grep -q "^library " "$file" && ! grep -q "^part " "$file"; then
        if grep -q "class \|void \|Future\|Stream" "$file"; then
            echo "  ⚠️  $file - No imports (might be incomplete)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi

    # Report issues
    if [ "$OPEN_BRACES" -ne "$CLOSE_BRACES" ]; then
        echo "  ❌ $file - Mismatched braces (open: $OPEN_BRACES, close: $CLOSE_BRACES)"
        ERRORS=$((ERRORS + 1))
    fi

    if [ "$OPEN_PARENS" -ne "$CLOSE_PARENS" ]; then
        echo "  ❌ $file - Mismatched parentheses (open: $OPEN_PARENS, close: $CLOSE_PARENS)"
        ERRORS=$((ERRORS + 1))
    fi

    if [ "$OPEN_BRACKETS" -ne "$CLOSE_BRACKETS" ]; then
        echo "  ❌ $file - Mismatched brackets (open: $OPEN_BRACKETS, close: $CLOSE_BRACKETS)"
        ERRORS=$((ERRORS + 1))
    fi

    if [ "$ERRORS" -eq 0 ]; then
        echo "  ✓ $file"
        VALID=$((VALID + 1))
    fi
done

echo
echo "============================================================"
echo "Results:"
echo "  Total files: $TOTAL"
echo "  Valid: $VALID"
echo "  Warnings: $WARNINGS"
echo "  Errors: $((TOTAL - VALID))"

if [ "$VALID" -eq "$TOTAL" ]; then
    echo "  Status: ✅ ALL FILES VALID"
    echo "============================================================"
    exit 0
else
    echo "  Status: ❌ SOME FILES HAVE ERRORS"
    echo "============================================================"
    exit 1
fi
