------------------------------------------------------------------------------
--                              Ada Web Server                              --
--                                                                          --
--                            Copyright (C) 2004                            --
--                                ACT-Europe                                --
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

with Ada.Streams.Stream_IO;
with Ada.Text_IO;

with AWS.Attachments;
with AWS.Client;
with AWS.MIME;
with AWS.Response;
with AWS.Server;
with AWS.Status;
with AWS.Translator;
with AWS.Utils;

with Get_Free_Port;

procedure Attachment is

   use Ada;
   use AWS;

   Att      : AWS.Attachments.List;
   Response : AWS.Response.Data;

   Port     : Natural := 6734;

   task Server is
      entry Started;
      entry Stop;
   end Server;

   procedure Output (Filename : in String; Content_Type : in String);
   --  Output content of filename. Output is base64 encoded if content type is
   --  not textual data.

   ------------
   -- Output --
   ------------

   procedure Output (Filename : in String; Content_Type : in String) is
      use Ada.Streams;
      File   : Stream_IO.File_Type;
      Buffer : Stream_Element_Array (1 .. 4_048);
      Last   : Stream_Element_Offset;
   begin
      Stream_IO.Open (File, Stream_IO.In_File, Filename);
      Stream_IO.Read (File, Buffer, Last);

      Text_IO.Put_Line ("File : " & Filename & " " & Content_Type);

      if MIME.Is_Text (Content_Type) then
         Text_IO.Put_Line (Translator.To_String (Buffer (1 .. Last)));
      else
         Text_IO.Put_Line (Translator.Base64_Encode (Buffer (1 .. Last)));
      end if;

      Text_IO.New_Line;

      Stream_IO.Close (File);
   end Output;

   -----------
   -- HW_CB --
   -----------

   function HW_CB (Request : in AWS.Status.Data) return AWS.Response.Data is
      Att_List : constant AWS.Attachments.List
        := AWS.Status.Attachments (Request);
      Atts     : constant Integer := AWS.Attachments.Count (Att_List);
      Att      : AWS.Attachments.Element;
   begin
      for J in 1 .. Atts loop
         Att := AWS.Attachments.Get (Att_List, J);

         Output (AWS.Attachments.Local_Filename (Att),
                 AWS.Attachments.Content_Type (Att));
      end loop;

      return AWS.Response.Build
        ("text/html", "<p> Got" & Integer'Image (Atts) & " attachments");
   end HW_CB;

   ------------
   -- Server --
   ------------

   task body Server is
      WS : AWS.Server.HTTP;
   begin
      Get_Free_Port (Port);

      AWS.Server.Start
        (WS, "Attachment Server",
         Callback => HW_CB'Unrestricted_Access, Port => Port);

      accept Started;

      accept Stop;

      AWS.Server.Shutdown (WS);
   end Server;

begin
   AWS.Attachments.Add
     (Attachments => Att,
      Filename    => "attachment1.txt",
      Content_Id  => "My-Txt-Attachment");

   AWS.Attachments.Add
     (Attachments => Att,
      Filename    => "attachment2.txt",
      Content_Id  => "My-Second-Txt-Attachment");

   AWS.Attachments.Add
     (Attachments => Att,
      Filename    => "../demos/aws_logo.png",
      Content_Id  => "My-Png-Attachment");

   Server.Started;

   Response := Aws.Client.Post
     (URL         => "http://localhost:" & Utils.Image (Port) & "/any_URI",
      Data        => "Dummy message",
      Attachments => Att);

   Server.Stop;
end Attachment;
