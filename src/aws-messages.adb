------------------------------------------------------------------------------
--                              Ada Web Server                              --
--                                                                          --
--                            Copyright (C) 2000                            --
--                               Pascal Obry                                --
--                                                                          --
--  This library is free software; you can redistribute it and/or modify    --
--  it under the terms of the GNU General Public License as published by    --
--  the Free Software Foundation; either version 2 of the License, or (at   --
--  your option) any later version.                                         --
--                                                                          --
--  This library is distributed in the hope that it will be useful, but     --
--  WITHOUT ANY WARRANTY; without even the implied warranty of              --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       --
--  General Public License for more details.                                --
--                                                                          --
--  You should have received a copy of the GNU General Public License       --
--  along with this library; if not, write to the Free Software Foundation, --
--  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.          --
--                                                                          --
--  As a special exception, if other files instantiate generics from this   --
--  unit, or you link this unit with other files to produce an executable,  --
--  this  unit  does not  by itself cause  the resulting executable to be   --
--  covered by the GNU General Public License. This exception does not      --
--  however invalidate any other reasons why the executable file  might be  --
--  covered by the  GNU Public License.                                     --
------------------------------------------------------------------------------

--  $Id$

package body AWS.Messages is

   type String_Access is access constant String;

   S100_Code : aliased constant String := "100";
   S101_Code : aliased constant String := "101";
   S200_Code : aliased constant String := "200";
   S201_Code : aliased constant String := "201";
   S202_Code : aliased constant String := "202";
   S203_Code : aliased constant String := "203";
   S204_Code : aliased constant String := "204";
   S205_Code : aliased constant String := "205";
   S206_Code : aliased constant String := "206";
   S300_Code : aliased constant String := "300";
   S301_Code : aliased constant String := "301";
   S302_Code : aliased constant String := "302";
   S303_Code : aliased constant String := "303";
   S304_Code : aliased constant String := "304";
   S305_Code : aliased constant String := "305";
   S307_Code : aliased constant String := "307";
   S400_Code : aliased constant String := "400";
   S401_Code : aliased constant String := "401";
   S402_Code : aliased constant String := "402";
   S403_Code : aliased constant String := "403";
   S404_Code : aliased constant String := "404";
   S405_Code : aliased constant String := "405";
   S406_Code : aliased constant String := "406";
   S407_Code : aliased constant String := "407";
   S408_Code : aliased constant String := "408";
   S409_Code : aliased constant String := "409";
   S410_Code : aliased constant String := "410";
   S411_Code : aliased constant String := "411";
   S412_Code : aliased constant String := "412";
   S413_Code : aliased constant String := "413";
   S414_Code : aliased constant String := "414";
   S415_Code : aliased constant String := "415";
   S416_Code : aliased constant String := "416";
   S417_Code : aliased constant String := "417";
   S500_Code : aliased constant String := "500";
   S501_Code : aliased constant String := "501";
   S502_Code : aliased constant String := "502";
   S503_Code : aliased constant String := "503";
   S504_Code : aliased constant String := "504";
   S505_Code : aliased constant String := "505";

   S100_Message : aliased constant String := "Continue";
   S101_Message : aliased constant String := "Switching Protocols";
   S200_Message : aliased constant String := "OK";
   S201_Message : aliased constant String := "Create";
   S202_Message : aliased constant String := "Accepted";
   S203_Message : aliased constant String := "Non-Authoritative Information";
   S204_Message : aliased constant String := "No Content";
   S205_Message : aliased constant String := "Reset Content";
   S206_Message : aliased constant String := "Partial Content";
   S300_Message : aliased constant String := "Multiple Choices";
   S301_Message : aliased constant String := "Moved Permanently";
   S302_Message : aliased constant String := "Found";
   S303_Message : aliased constant String := "See Other";
   S304_Message : aliased constant String := "Not Modified";
   S305_Message : aliased constant String := "Use Proxy";
   S307_Message : aliased constant String := "Temporary Redirect";
   S400_Message : aliased constant String := "Bad Request";
   S401_Message : aliased constant String := "Unauthorized";
   S402_Message : aliased constant String := "Payment Required";
   S403_Message : aliased constant String := "Forbidden";
   S404_Message : aliased constant String := "Not Found";
   S405_Message : aliased constant String := "Method Not Allowed";
   S406_Message : aliased constant String := "Not Acceptable";
   S407_Message : aliased constant String := "Proxy Authentification Required";
   S408_Message : aliased constant String := "Request Time-out";
   S409_Message : aliased constant String := "Conflict";
   S410_Message : aliased constant String := "Gone";
   S411_Message : aliased constant String := "Length Required";
   S412_Message : aliased constant String := "Precondition Failed";
   S413_Message : aliased constant String := "Request Entity Too Large";
   S414_Message : aliased constant String := "Request-URI Too Large";
   S415_Message : aliased constant String := "Unsupported Media Type";
   S416_Message : aliased constant String := "Requestd range not satisfiable";
   S417_Message : aliased constant String := "Expectation Failed";
   S500_Message : aliased constant String := "Internal Server Error";
   S501_Message : aliased constant String := "Not Implemented";
   S502_Message : aliased constant String := "Bad Gateway";
   S503_Message : aliased constant String := "Service Unavailable";
   S504_Message : aliased constant String := "Gateway Time-out";
   S505_Message : aliased constant String := "HTTP Version not supported";

   type Status_Data is record
      Code          : String_Access;
      Reason_Phrase : String_Access;
   end record;

   Status_Messages : array (Status_Code) of Status_Data
     := (S100 => (S100_Code'Access, S100_Message'Access),
         S101 => (S101_Code'Access, S101_Message'Access),
         S200 => (S200_Code'Access, S200_Message'Access),
         S201 => (S201_Code'Access, S201_Message'Access),
         S202 => (S202_Code'Access, S202_Message'Access),
         S203 => (S203_Code'Access, S203_Message'Access),
         S204 => (S204_Code'Access, S204_Message'Access),
         S205 => (S205_Code'Access, S205_Message'Access),
         S206 => (S206_Code'Access, S206_Message'Access),
         S300 => (S300_Code'Access, S300_Message'Access),
         S301 => (S301_Code'Access, S301_Message'Access),
         S302 => (S302_Code'Access, S302_Message'Access),
         S303 => (S303_Code'Access, S303_Message'Access),
         S304 => (S304_Code'Access, S304_Message'Access),
         S305 => (S305_Code'Access, S305_Message'Access),
         S307 => (S307_Code'Access, S307_Message'Access),
         S400 => (S400_Code'Access, S400_Message'Access),
         S401 => (S401_Code'Access, S401_Message'Access),
         S402 => (S402_Code'Access, S402_Message'Access),
         S403 => (S403_Code'Access, S403_Message'Access),
         S404 => (S404_Code'Access, S404_Message'Access),
         S405 => (S405_Code'Access, S405_Message'Access),
         S406 => (S406_Code'Access, S406_Message'Access),
         S407 => (S407_Code'Access, S407_Message'Access),
         S408 => (S408_Code'Access, S408_Message'Access),
         S409 => (S409_Code'Access, S409_Message'Access),
         S410 => (S410_Code'Access, S410_Message'Access),
         S411 => (S411_Code'Access, S411_Message'Access),
         S412 => (S412_Code'Access, S412_Message'Access),
         S413 => (S413_Code'Access, S413_Message'Access),
         S414 => (S414_Code'Access, S414_Message'Access),
         S415 => (S415_Code'Access, S415_Message'Access),
         S416 => (S416_Code'Access, S416_Message'Access),
         S417 => (S417_Code'Access, S417_Message'Access),
         S500 => (S500_Code'Access, S500_Message'Access),
         S501 => (S501_Code'Access, S501_Message'Access),
         S502 => (S502_Code'Access, S502_Message'Access),
         S503 => (S503_Code'Access, S503_Message'Access),
         S504 => (S504_Code'Access, S504_Message'Access),
         S505 => (S505_Code'Access, S505_Message'Access));

   -----------------
   -- Status_Line --
   -----------------

   function Status_Line (Code : in Status_Code) return String is
   begin
      return HTTP_Version & ' '
        & Status_Messages (Code).Code.all & ' '
        & Status_Messages (Code).Reason_Phrase.all;
   end Status_Line;

   --------------------
   -- Content_Length --
   --------------------

   function Content_Length (Size : in Positive) return String is
   begin
      return "Content-Length:" & Positive'Image (Size);
   end Content_Length;

   ------------------
   -- Content_Type --
   ------------------

   function Content_Type (Format : in String) return String is
   begin
      return "Content-Type: " & Format;
   end Content_Type;

end AWS.Messages;
