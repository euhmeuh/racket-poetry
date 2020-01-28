"use strict";

/*
================================================================================

  Copyright (c) 2020 Jérôme Martin <rilouw.eu>
  The code for this project is released under the terms of the GNU AGPLv3.

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.

================================================================================
*/

const Base64 = (function(){

  const dict = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

  function decode(base64) {
    const input = base64.replace(/[^A-Za-z0-9\+\/\=]/g, "");
    const length = parseInt((input.length / 4) * 3, 10);
    const result = new Uint8Array(length);

    let char1, char2, char3;
    let byte1, byte2, byte3, byte4;
    let i = 0;
    let j = 0;

    for (i = 0; i < length; i += 3) {
      byte1 = dict.indexOf(input.charAt(j++));
      byte2 = dict.indexOf(input.charAt(j++));
      byte3 = dict.indexOf(input.charAt(j++));
      byte4 = dict.indexOf(input.charAt(j++));

      char1 = (byte1 << 2) | (byte2 >> 4);
      char2 = ((byte2 & 15) << 4) | (byte3 >> 2);
      char3 = ((byte3 & 3) << 6) | byte4;

      result[i] = char1;
      if (byte3 != 64) result[i+1] = char2;
      if (byte4 != 64) result[i+2] = char3;
    }

    return result;
  }

  return { decode };
}());
