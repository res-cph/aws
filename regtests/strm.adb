------------------------------------------------------------------------------
--                              Ada Web Server                              --
--                                                                          --
--                         Copyright (C) 2000-2004                          --
--                               ACT-Europe                                 --
--                                                                          --
--  Authors: Dmitriy Anisimkov - Pascal Obry                                --
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

--  ~ MAIN [STD]

--  Test for user defined stream.

with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Streams;

with AWS.Server.Log;
with AWS.Client;
with AWS.Status;
with AWS.MIME;
with AWS.Response;
with AWS.Messages;

with AWS.Resources.Streams;

with User_Strm;

procedure Strm is

   use Ada;
   use Ada.Text_IO;
   use AWS;

   function CB (Request : in Status.Data) return Response.Data;

   procedure Compare_Message;

   task Server is
      entry Wait_Start;
      entry Stop;
   end Server;

   HTTP    : AWS.Server.HTTP;
   Connect : Client.HTTP_Connection;
   R       : Response.Data;

   File_Size : constant := 98_100;
   --  !!! Do not change the file size.
   --  It is just for control error when only CRC in the last chunk
   --  of the deflate compressed data.

   Base_URL : constant String := "http://localhost:1238";

   Length_Defined_URI   : constant String := "/length_defined";
   Length_Undefined_URI : constant String := "/length_undefined";
   Deflated_URI         : constant String := "/deflate-it";
   GZip_URI             : constant String := "/gzip-it";

   --------
   -- CB --
   --------

   function CB (Request : in Status.Data) return Response.Data is
      File : AWS.Resources.Streams.Stream_Access
        := new User_Strm.File_Tagged;
   begin

      User_Strm.Create
        (Resource       => File.all,
         Undefined_Size => Status.URI (Request) /= Length_Defined_URI,
         Size           => File_Size);

      if Status.URI (Request) = Deflated_URI then
         return AWS.Response.Stream
           ("text/plain",
            File,
            Encoding => AWS.Messages.Deflate);

      elsif Status.URI (Request) = GZip_URI then
         return AWS.Response.Stream
           ("text/plain",
            File,
            Encoding => AWS.Messages.GZip);

      else
         return AWS.Response.Stream
           ("text/plain",
            File);
      end if;
   end CB;

   ------------
   -- Server --
   ------------

   task body Server is
   begin
      AWS.Server.Start
        (HTTP, "Testing user defined stream.",
         CB'Unrestricted_Access, Port => 1238, Max_Connection => 3);

      AWS.Server.Log.Start (HTTP);

      accept Wait_Start;
      accept Stop;

   exception
      when E : others =>
         Put_Line ("Server Error " & Exceptions.Exception_Information (E));
   end Server;

   ---------------------
   -- Compare_Message --
   ---------------------

   procedure Compare_Message is
      use Ada.Streams;

      Message      : constant Stream_Element_Array
        := Response.Message_Body (R);

      Same_Message : Stream_Element_Array (Message'Range);

      File : User_Strm.File_Tagged;
      Last : Stream_Element_Offset;
   begin
      User_Strm.Create (File, File_Size, False);
      User_Strm.Read (File, Same_Message, Last);

      if Message = Same_Message
        and then Last = Message'Last
        and then User_Strm.End_Of_File (File)
      then
         Put_Line ("Ok.");
      else
         Put_Line
           (Boolean'Image (Message = Same_Message)
            & ' ' & Boolean'Image (Last = Message'Last)
            & ' ' & Boolean'Image (User_Strm.End_Of_File (File))
            & Integer'Image (Message'Length));

         Put_Line ("Error.");
      end if;
   end Compare_Message;

begin
   Server.Wait_Start;

   --  Keep-alive test.

   Client.Create
     (Connection => Connect,
      Host       => Base_URL,
      Timeouts   => (5.0, 5.0));

   Client.Get (Connect, R, Length_Defined_URI);
   Compare_Message;

   Client.Get (Connect, R, Length_Undefined_URI);
   Compare_Message;

   Client.Get (Connect, R, Deflated_URI);
   Compare_Message;

   Client.Get (Connect, R, GZip_URI);
   Compare_Message;

   Client.Close (Connect);

   --  Non keep-alive test.

   R := Client.Get (Base_URL & Length_Defined_URI);
   Compare_Message;

   R := Client.Get (Base_URL & Length_Undefined_URI);
   Compare_Message;

   R := Client.Get (Base_URL & Deflated_URI);
   Compare_Message;

   R := Client.Get (Base_URL & GZip_URI);
   Compare_Message;

   Server.Stop;

exception
   when E : others =>
      Server.Stop;
      Put_Line ("Main Error " & Exceptions.Exception_Information (E));
end Strm;
