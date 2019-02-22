-module(example).

-export([advance/1,
         create/0,
         direction/1,
         left/1,
         place/3,
         position/1,
         right/1]).

advance( Robot ) -> Robot ! advance.

create() -> erlang:spawn( fun() -> loop( undefined, {undefined, undefined} ) end ).

left( Robot ) -> Robot ! {turn, left}.

direction( Robot ) -> request( Robot, direction ).

place( Robot, Direction, Position ) -> Robot ! {place, Direction, Position}.

position( Robot ) -> request( Robot, position ).

right( Robot ) -> Robot ! {turn, right}.



loop( Direction, Position ) ->
  receive
    advance ->
      loop( Direction, new_position(Direction, Position) );
    {direction, Pid} ->
      Pid ! {direction, Direction},
      loop( Direction, Position );
    {turn, Turn} ->
      loop( new_direction(Direction, Turn), Position );
    {place, New_direction, New_position} ->
      loop( New_direction, New_position );
    {position, Pid} ->
      Pid ! {position, Position},
      loop( Direction, Position )
  end.

new_direction( north, right ) -> east;
new_direction( south, right ) -> west;
new_direction( east, right ) -> south;
new_direction( west, right ) -> north;
new_direction( north, left ) -> west;
new_direction( south, left ) -> east;
new_direction( east, left ) -> north;
new_direction( west, left ) -> south.

new_position( north, {X, Y} ) -> {X, Y + 1};
new_position( south, {X, Y} ) -> {X, Y - 1};
new_position( east, {X, Y} ) -> {X + 1, Y};
new_position( west, {X, Y} ) -> {X - 1, Y}.

request( Robot, Request ) ->
  Robot ! {Request, erlang:self()},
  receive
    {Request, Answer} -> Answer
  end.
