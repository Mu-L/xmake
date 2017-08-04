--!The Make-like Build Utility based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2017, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        api.lua
--

-- get function name and function info
--
-- sigsetjmp
-- sigsetjmp((void*)0, 0)
-- sigsetjmp{sigsetjmp((void*)0, 0);}
-- sigsetjmp{int a = 0; sigsetjmp((void*)a, a);}
--
function _funcinfo(func)

    -- parse name and code
    local name, code = string.match(func, "(.+){(.+)}")
    if code == nil then
        local pos = func:find("%(")
        if pos then
            name = func:sub(1, pos - 1)
            code = func
        else
            name = func
            code = string.format("volatile void* p%s = (void*)&%s;", name, name)
        end
    end

    -- ok
    return name:trim(), code
end

-- add c function
function _api_add_cfunc(interp, module, alias, links, includes, func)

    -- parse the function info
    local funcname, funccode = _funcinfo(func)

    -- make the option name
    local name = nil
    if module ~= nil then
        name = format("__%s_%s", module, funcname)
    else
        name = format("__%s", funcname)
    end

    -- uses the alias name
    if alias ~= nil then
        funcname = alias
    end

    -- make the option define
    local define = nil
    if module ~= nil then
        define = format("$(prefix)_%s_HAVE_%s", module:upper(), funcname:upper())
    else
        define = format("$(prefix)_HAVE_%s", funcname:upper())
    end

    -- save the current scope
    local scope = interp:scope_save()

    -- check option
    interp:api_call("option", name)
    interp:api_call("set_category", "cfuncs")
    interp:api_call("add_cfuncs", func)
    if links then interp:api_call("add_links", links) end
    if includes then interp:api_call("add_cincludes", includes) end
    interp:api_call("add_defines_h", define)

    -- restore the current scope
    interp:scope_restore(scope)

    -- add this option 
    interp:api_call("add_options", name)
end

-- add c functions
function _api_add_cfuncs(interp, module, links, includes, ...)

    -- done
    for _, func in ipairs({...}) do
        _api_add_cfunc(interp, module, nil, links, includes, func)
    end
end

-- add c++ function
function _api_add_cxxfunc(interp, module, alias, links, includes, func)

    -- parse the function info
    local funcname, funccode = _funcinfo(func)

    -- make the option name
    local name = nil
    if module ~= nil then
        name = format("__%s_%s", module, funcname)
    else
        name = format("__%s", funcname)
    end

    -- uses the alias name
    if alias ~= nil then
        funcname = alias
    end

    -- make the option define
    local define = nil
    if module ~= nil then
        define = format("$(prefix)_%s_HAVE_%s", module:upper(), funcname:upper())
    else
        define = format("$(prefix)_HAVE_%s", funcname:upper())
    end

    -- save the current scope
    local scope = interp:scope_save()

    -- check option
    interp:api_call("option", name)
    interp:api_call("set_category", "cxxfuncs")
    interp:api_call("add_cxxfuncs", func)
    if links then interp:api_call("add_links", links) end
    if includes then interp:api_call("add_cxxincludes", includes) end
    interp:api_call("add_defines_h", define)

    -- restore the current scope
    interp:scope_restore(scope)

    -- add this option 
    interp:api_call("add_options", name)
end

-- add c++ functions
function _api_add_cxxfuncs(interp, module, links, includes, ...)

    -- done
    for _, func in ipairs({...}) do
        _api_add_cxxfunc(interp, module, nil, links, includes, func)
    end
end


-- get apis
function apis()

    -- init apis
    _g.values = 
    {
        -- target.set_xxx
        "target.set_config_h_prefix" -- deprecated
        -- target.add_xxx
    ,   "target.add_links"
    ,   "target.add_cflags"
    ,   "target.add_cxflags"
    ,   "target.add_cxxflags"
    ,   "target.add_ldflags"
    ,   "target.add_arflags"
    ,   "target.add_shflags"
    ,   "target.add_defines"
    ,   "target.add_undefines"
    ,   "target.add_defines_h"
    ,   "target.add_undefines_h"
    ,   "target.add_frameworks"
        -- option.add_xxx
    ,   "option.add_cincludes"
    ,   "option.add_cxxincludes"
    ,   "option.add_cfuncs"
    ,   "option.add_cxxfuncs"
    ,   "option.add_ctypes"
    ,   "option.add_cxxtypes"
    ,   "option.add_links"
    ,   "option.add_cflags"
    ,   "option.add_cxflags"
    ,   "option.add_cxxflags"
    ,   "option.add_ldflags"
    ,   "option.add_arflags"
    ,   "option.add_shflags"
    ,   "option.add_defines"
    ,   "option.add_defines_h"
    ,   "option.add_defines_if_ok"
    ,   "option.add_defines_h_if_ok"
    ,   "option.add_undefines"
    ,   "option.add_undefines_h"
    ,   "option.add_undefines_if_ok"
    ,   "option.add_undefines_h_if_ok"
    ,   "option.add_frameworks"
    }
    _g.pathes = 
    {
        -- target.set_xxx
        "target.set_headerdir"
    ,   "target.set_config_h" -- deprecated
    ,   "target.set_config_header"
    ,   "target.set_pcheader"
    ,   "target.set_pcxxheader"
        -- target.add_xxx
    ,   "target.add_headers"
    ,   "target.add_linkdirs"
    ,   "target.add_rpathdirs"
    ,   "target.add_includedirs"
    ,   "target.add_frameworkdirs"
        -- option.add_xxx
    ,   "option.add_linkdirs"
    ,   "option.add_rpathdirs"
    ,   "option.add_includedirs"
    ,   "option.add_frameworkdirs"
    }
    _g.dictionary =
    {
        -- option.add_xxx
        "option.add_csnippet"
    ,   "option.add_cxxsnippet"
    }
    _g.custom = 
    {
        -- target.add_xxx
        {"target.add_cfunc",        _api_add_cfunc      }
    ,   {"target.add_cfuncs",       _api_add_cfuncs     }
    ,   {"target.add_cxxfunc",      _api_add_cxxfunc    }
    ,   {"target.add_cxxfuncs",     _api_add_cxxfuncs   }
    }

    -- ok
    return _g
end


