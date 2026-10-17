#include "utils.h"

#include <windows.h>

#include <iostream>
#include <string>

static_assert(sizeof(wchar_t) == 2, "Windows UTF-16 requires 16-bit wchar_t.");

bool ExpectConversion(const char* name, const wchar_t* input,
                      const std::string& expected) {
  const std::string actual = Utf8FromUtf16(input);
  if (actual != expected) {
    std::cerr << name << ": expected " << expected.size() << " UTF-8 bytes, got "
              << actual.size() << ".\n";
    return false;
  }
  return true;
}

int main() {
  bool passed = true;
  passed = ExpectConversion("null", nullptr, "") && passed;
  passed = ExpectConversion("empty", L"", "") && passed;
  passed = ExpectConversion("ASCII", L"--route=/switches", "--route=/switches") &&
           passed;
  passed = ExpectConversion(
               "Unicode", L"caf\u00e9 \u0633\u0644\u0627\u0645 \U0001f600",
               u8"caf\u00e9 \u0633\u0644\u0627\u0645 \U0001f600") &&
           passed;

  const wchar_t unpaired_high[] = {static_cast<wchar_t>(0xd800), 0};
  const wchar_t unpaired_low[] = {static_cast<wchar_t>(0xdc00), 0};
  const wchar_t invalid_pair[] = {static_cast<wchar_t>(0xd800), L'x', 0};
  passed = ExpectConversion("unpaired high surrogate", unpaired_high, "") &&
           passed;
  passed = ExpectConversion("unpaired low surrogate", unpaired_low, "") && passed;
  passed = ExpectConversion("invalid surrogate pair", invalid_pair, "") && passed;

  const size_t max_chars = UNICODE_STRING_MAX_CHARS;
  const std::wstring at_limit(max_chars, L'x');
  passed = ExpectConversion("at Windows character limit", at_limit.c_str(),
                            std::string(max_chars, 'x')) &&
           passed;
  const std::wstring beyond_limit(max_chars + 32, L'x');
  passed = ExpectConversion("bounded long input", beyond_limit.c_str(),
                            std::string(max_chars, 'x')) &&
           passed;

  // A pair cut by the input bound must fail instead of emitting invalid UTF-8.
  std::wstring split_surrogate(max_chars - 1, L'x');
  split_surrogate.push_back(static_cast<wchar_t>(0xd83d));
  split_surrogate.push_back(static_cast<wchar_t>(0xde00));
  passed = ExpectConversion("surrogate at input bound", split_surrogate.c_str(),
                            "") &&
           passed;
  return passed ? 0 : 1;
}
