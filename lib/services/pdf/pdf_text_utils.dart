class PdfTextUtils {
  /// Cleans HTML, smart quotes, smart dashes, and Unicode symbols
  /// to prevent font fallback issues in the PDF engine.
  static String clean(String? text) {
    if (text == null || text.isEmpty) return '';
    
    // 1. Basic HTML cleaning
    String result = text.replaceAll(
      RegExp(r'</p>|<br>|<br\s*/>', caseSensitive: false),
      '\n\n',
    );
    result = result.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');
    result = result.replaceAll(RegExp(r'<li>', caseSensitive: false), '- '); // Use hyphen instead of bullet
    result = result.replaceAll(
      RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true),
      '',
    );
    
    // 2. Common entities
    result = result.replaceAll('&nbsp;', ' ');
    result = result.replaceAll('&amp;', '&');
    result = result.replaceAll('&lt;', '<');
    result = result.replaceAll('&gt;', '>');
    result = result.replaceAll('&quot;', '"');
    
    // 3. Smart quotes & dashes (Source of most Unicode issues)
    result = result.replaceAll('&#8217;', "'");
    result = result.replaceAll('&#8211;', "-");
    result = result.replaceAll('&#8212;', "--");
    result = result.replaceAll('&#8220;', '"');
    result = result.replaceAll('&#8221;', '"');
    result = result.replaceAll('’', "'");
    result = result.replaceAll('–', "-");
    result = result.replaceAll('—', "--");
    result = result.replaceAll('“', '"');
    result = result.replaceAll('”', '"');
    
    // 4. Symbols
    result = result.replaceAll('₹', 'Rs.');
    result = result.replaceAll('&#8377;', 'Rs.');
    result = result.replaceAll('\u00A0', ' '); // Non-breaking space
    result = result.replaceAll('•', '-'); // Generic bullet to hyphen
    
    // 5. Final safety cleanup (Remove any remaining high Unicode that Roboto might hate)
    // We keep basic punctuation and standard symbols.
    // result = result.replaceAll(RegExp(r'[^\x00-\x7F]+'), ' '); // Uncomment if still failing
    
    // 6. Normalization
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return result.trim();
  }
}
