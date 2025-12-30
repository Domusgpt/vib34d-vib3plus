#!/bin/bash

echo "=========================================="
echo "  VIB34D Interactive Demo Server"
echo "=========================================="
echo

# Try different server options
if command -v python3 &> /dev/null; then
    echo "✓ Starting Python HTTP server..."
    echo "  URL: http://localhost:8000"
    echo "  Press Ctrl+C to stop"
    echo
    python3 -m http.server 8000
elif command -v python &> /dev/null; then
    echo "✓ Starting Python 2 HTTP server..."
    echo "  URL: http://localhost:8000"
    echo "  Press Ctrl+C to stop"
    echo
    python -m SimpleHTTPServer 8000
elif command -v php &> /dev/null; then
    echo "✓ Starting PHP server..."
    echo "  URL: http://localhost:8000"
    echo "  Press Ctrl+C to stop"
    echo
    php -S localhost:8000
else
    echo "❌ No HTTP server available"
    echo
    echo "Please install one of:"
    echo "  - Python 3: apt-get install python3"
    echo "  - PHP: apt-get install php"
    echo "  - Node.js: npm install -g http-server"
    echo
    echo "Or open index.html directly in your browser"
    exit 1
fi
