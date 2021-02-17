-- Node Registrations

minetest.register_node("game:grassy_grass",
{
  description = "Ground Block",
  tiles = {"grassy_grass.png"},
  light_source = 12,
})

minetest.register_node("game:grassy_dirt",
{
  description = "Ground Block",
  tiles = {"grassy_dirt.png"},
  light_source = 12,
})

minetest.register_node("game:grassy_hedge",
{
  description = "Ground Block",
  tiles = {"grassy_hedge.png"},
  light_source = 12,
})

local function map_function(maze, player)
    local loc_maze = maze
    width = loc_maze.width
    height = loc_maze.height

    --Copy to the map
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=width*2,y=4,z=height*2})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local grass =   minetest.get_content_id("game:grassy_grass")
    local dirt   =   minetest.get_content_id("game:grassy_dirt")
    local hedge  =   minetest.get_content_id("game:grassy_hedge")
    local invisble = minetest.get_content_id("game:inv")
    local air =      minetest.get_content_id("air")
    
    --Set up the level itself
    for z=1, width*2 do --z
        for x=1, height*2 do --x
            if loc_maze[x][z] == 1 then
                data[a:index(x, 0, z)] = grass
            else
                data[a:index(x, 0, z)] = dirt
                for y=1,4 do
                    data[a:index(x, y, z)] = hedge
                end
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
    
    --player target coords
    player_x = width+(width*2)%4
    player_z = height+(height*2)%4
    
    --Lets now overwrite the channel for the player to fall into:
    local emin, emax = vm:read_from_map({x=player_x-1,y=4,z=player_z-1}, {x=player_x+1,y=32,z=player_z+1})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    for y=5,32 do
        for x=player_x-1, player_x+1 do
            for z=player_z-1, player_z+1 do
                data[a:index(x, y, z)] = air
            end
        end
        --Add the invisible channel
        data[a:index(player_x-1, y, player_z)] = invisble
        data[a:index(player_x+1, y, player_z)] = invisble
        data[a:index(player_x, y, player_z-1)] = invisble
        data[a:index(player_x, y, player_z+1)] = invisble
    end
    vm:set_data(data)
    vm:write_to_map(true)
    
    --Finally, move  the player
    player:set_velocity({x=0,y=0,z=0})
    player:set_pos({x=player_x,y=32,z=player_z})
end

local function cleanup(width, height)
    --Copy to the map
    local vm         = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=width*2,y=4,z=height*2})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local air =      minetest.get_content_id("air")
    
    --Generally a good idea to zero it out
    for z=0, width*2 do --z
        for y=0,4 do --
            for x=0, height*2 do --x
                data[a:index(x, y, z)] = air
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
    
    --player target coords
    player_x = width+(width*2)%4
    player_z = height+(height*2)%4
    
    --Lets now overwrite the channel for the player to fall into:
    local emin, emax = vm:read_from_map({x=player_x-1,y=4,z=player_z-1}, {x=player_x+1,y=32,z=player_z+1})
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    for y=5,32 do
        for x=player_x-1, player_x+1 do
            for z=player_z-1, player_z+1 do
                data[a:index(x, y, z)] = air
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
end

register_style("grassy","grassy", map_function, cleanup)