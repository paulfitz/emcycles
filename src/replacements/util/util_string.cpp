/*
 * Copyright 2011, Blender Foundation.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

#include <stdarg.h>
#include <stdio.h>
#include <assert.h>

//#include <boost/algorithm/string.hpp>

#include "util_foreach.h"
#include "util_string.h"

#ifdef _WIN32
#ifndef vsnprintf
#define vsnprintf _vsnprintf
#endif
#endif

CCL_NAMESPACE_BEGIN

string string_printf(const char *format, ...)
{
	vector<char> str(128, 0);

	while(1) {
		va_list args;
		int result;

		va_start(args, format);
		result = vsnprintf(&str[0], str.size(), format, args);
		va_end(args);

		if(result == -1) {
			/* not enough space or formatting error */
			if(str.size() > 65536) {
				assert(0);
				return string("");
			}

			str.resize(str.size()*2, 0);
			continue;
		}
		else if(result >= (int)str.size()) {
			/* not enough space */
			str.resize(result + 1, 0);
			continue;
		}

		return string(&str[0]);
	}
}

string string_d(int x) {
  char buf[256];
  sprintf(buf,"%d",x);
  return buf;
}

string string_0d(int x, int n) {
  string result = string_d(x);
  while (result.length()<n) {
    result = string("0") + result;
  }
  return result;
}

bool string_iequals(const string& a, const string& b)
{
	if(a.size() == b.size()) {
		for(size_t i = 0; i < a.size(); i++)
			if(toupper(a[i]) != toupper(b[i]))
				return false;

		return true;
	}

	return false;
}

void string_split(vector<string>& tokens, const string& str, const string& separators)
{
  string str_copy = str + separators[0];
  vector<string> split;

  //vector<string> split2;
  //boost::split(split2, str, boost::is_any_of(separators), boost::token_compress_on);

  char *saveptr = (char *)str_copy.c_str();
  char *initptr = saveptr;
  char *result = NULL;
  do {
    result = strtok_r(initptr,separators.c_str(),&saveptr);
    if (result) split.push_back(result);
    initptr = NULL;
  } while (result!=NULL);

  /*
  if (split!=split2) {
    printf("MISMATCH!\n");
    printf("string [%s] delim [%s]\n", str.c_str(), separators.c_str());
    for (string s : split) { printf("[%s] ", s.c_str()); } printf("\n");
    for (string s : split2) { printf("[%s] ", s.c_str()); } printf("\n");
    //exit(1);
  }
  */

  foreach(const string& token, split)
    if(token != "")
      tokens.push_back(token);
}

CCL_NAMESPACE_END

