------------------------------------------------------------------------------
--                              Ada Web Server                              --
--                                                                          --
--                            Copyright (C) 2003                            --
--                               ACT-Europe                                 --
--                                                                          --
--  Authors: Dmitriy Anisimokv - Pascal Obry                                --
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

with Ada.Text_IO;
with Ada.Exceptions;

with AWS.Server;
with AWS.Client;
with AWS.Status;
with AWS.MIME;
with AWS.Response;
with AWS.Messages;

procedure Auth2 is

   use Ada;
   use Ada.Text_IO;
   use AWS;

   function CB (Request : in Status.Data) return Response.Data;

   HTTP : AWS.Server.HTTP;

   R : Response.Data;

   --------
   -- CB --
   --------

   function CB (Request : in Status.Data) return Response.Data is
      Username : constant String
        := AWS.Status.Authorization_Name (Request);
      Password : constant String
        := AWS.Status.Authorization_Password (Request);
   begin
      return AWS.Response.Build
        ("text/plain", Username & " - " & Password);
   end CB;

begin
   AWS.Server.Start
     (HTTP, "Test authentication.",
      CB'Unrestricted_Access, Port => 1236, Max_Connection => 3);

   R := Client.Get ("http://localhost:1236", "toto", "toto_pwd");
   Text_IO.Put_Line (Response.Message_Body (R));

   R := Client.Get ("http://localhost:1236", "xyz", "_123_");
   Text_IO.Put_Line (Response.Message_Body (R));

   AWS.Server.Shutdown (HTTP);

exception
   when E : others =>
      Put_Line ("Main Error " & Exceptions.Exception_Information (E));
end Auth2;
