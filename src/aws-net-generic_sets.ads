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

--  Waiting on group of sockets for input/output availability.

with Ada.Finalization;

generic
   type Data_Type is private;
package AWS.Net.Generic_Sets is

   type Waiting_Mode is (Error, Input, Output, Both);
   --  Input  - would wait for data available for read from socket.
   --  Output - would wait output buffer availability for write.
   --  Both   - would wait for both Input and Output.
   --  Error  - would wait only for error state in socket.
   --  Note that all other waiting modes would be waiting for error state
   --  anyway.

   type Socket_Set_Type is limited private;

   procedure Add
     (Set    : in out Socket_Set_Type;
      Socket : in     Socket_Type'Class;
      Mode   : in     Waiting_Mode);
   --  Add socket to the set. Socket can be retreived from the set using
   --  Get_Socket.

   procedure Add
     (Set    : in out Socket_Set_Type;
      Socket : in     Socket_Access;
      Mode   : in     Waiting_Mode);
   --  Add socket to the set.

   function Count (Set : in Socket_Set_Type) return Natural;
   pragma Inline (Count);
   --  Returns the number of sockets in the Set.

   procedure Wait
     (Set     : in out Socket_Set_Type;
      Timeout : in     Duration);
   pragma Inline (Wait);
   --  Wait for a socket in the set to be ready for input or output operation.
   --  Raises Socket_Error if an error occurs.

   procedure Wait
     (Set     : in out Socket_Set_Type;
      Timeout : in     Duration;
      Count   :    out Natural);
   --  Wait for a socket in the set to be ready for input or output operation.
   --  Raises Socket_Error if an error occurs. Count would return number of
   --  activated sockets.

   function Is_Read_Ready
     (Set   : in Socket_Set_Type;
      Index : in Positive)
      return Boolean;
   pragma Inline (Is_Read_Ready);
   --  Return True if data could be read from socket and socket was in Input
   --  or Both waiting mode.

   function Is_Write_Ready
     (Set   : in Socket_Set_Type;
      Index : in Positive)
      return Boolean;
   pragma Inline (Is_Write_Ready);
   --  Return True if data could be written to socket and socket was in Output
   --  or Both waiting mode.

   function Is_Error
     (Set   : in Socket_Set_Type;
      Index : in Positive)
      return Boolean;
   pragma Inline (Is_Error);
   --  Return True if any error occured with socket while waiting.

   function In_Range
     (Set   : in Socket_Set_Type;
      Index : in Positive)
      return Boolean;
   pragma Inline (In_Range);
   --  Return True if Index is in socket set range.

   function Get_Socket
     (Set   : in Socket_Set_Type;
      Index : in Positive)
      return Socket_Type'Class;
   pragma Inline (Get_Socket);
   --  Return socket from the Index position or raise Constraint_Error
   --  if index is more than the number of sockets in set.

   function Get_Data
     (Set   : in Socket_Set_Type;
      Index : in Positive)
      return Data_Type;
   pragma Inline (Get_Data);

   procedure Set_Data
     (Set   : in out Socket_Set_Type;
      Index : in     Positive;
      Data  : in     Data_Type);
   pragma Inline (Set_Data);

   procedure Remove_Socket (Set : in out Socket_Set_Type; Index : in Positive);
   --  Delete socket from Index position from the Set. If the Index is not
   --  last position in the set, last socket would be placed instead of
   --  deleted one.

   procedure Next (Set : in Socket_Set_Type; Index : in out Positive);
   --  Looking for active socket starting from Index and return Index of the
   --  found active socket. After search use functions In_Range,
   --  Is_Write_Ready, Is_Read_Ready and Is_Error to be shure that active
   --  socket is found in the Set.

   procedure Reset (Set : in out Socket_Set_Type);
   --  Clear the set for another use

private

   type Poll_Set_Type;

   type Poll_Set_Access is access all Poll_Set_Type;

   type Socket_Record is record
      Socket    : Socket_Access;
      Allocated : Boolean;
      --  Set to True if socket was allocated internally in the set (it is the
      --  case when using the Add with Socket_Type'Class parameter).
      --  Needed to control free on delete.

      Data : Data_Type;
   end record;

   type Socket_Array is array (Positive range <>) of Socket_Record;

   type Socket_Array_Access is access all Socket_Array;

   type Socket_Set_Type is new Ada.Finalization.Limited_Controlled with record
      Poll : Poll_Set_Access;
      Set  : Socket_Array_Access;
      Last : Natural := 0;
   end record;

   procedure Finalize (Set : in out Socket_Set_Type);

end AWS.Net.Generic_Sets;