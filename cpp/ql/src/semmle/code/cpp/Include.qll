import semmle.code.cpp.Preprocessor

/**
 * A C/C++ `#include`, `#include_next`, or `#import` preprocessor
 * directive.
 */
class Include extends PreprocessorDirective, @ppd_include {
  override string toString() { result = "#include " + this.getIncludeText() }

  /**
   * Gets the token which occurs after `#include`, for example `"filename"`
   * or `&lt;filename>`.
   */
  string getIncludeText() { result = getHead() }

  /** Gets the file directly included by this `#include`. */
  File getIncludedFile() { includes(unresolveElement(this), unresolveElement(result)) }

  /**
   * Gets a file which might be transitively included by this `#include`.
   *
   * Note that as this isn't computed within the context of a particular
   * translation unit, it is often a slight over-approximation.
   */
  predicate provides(File l) {
      exists(Include i | this.getAnInclude*() = i and i.getIncludedFile() = l)
  }

  /**
   * A `#include` which appears in the file directly included by this
   * `#include`.
   */
  Include getAnInclude() {
      this.getIncludedFile() = result.getFile()
  }
}

/**
 * A `#include_next` preprocessor directive (a non-standard extension to
 * C/C++).
 */
class IncludeNext extends Include, @ppd_include_next {
  override string toString() {
    result = "#include_next " + getIncludeText()
  }
}

/**
 * A `#import` preprocessor directive (used heavily in Objective C, and
 * supported by GCC as an extension in C).
 */
class Import extends Include, @ppd_objc_import {
  override string toString() {
    result = "#import " + getIncludeText()
  }
}
