mutable struct Directory
    name::String
    files::Dict{String, UInt64}
    subdirs::Dict{String, Directory}
end
const File = Dict{String, UInt64}
const MAX_DIRSIZE = 100000
const LIST_CMD = "\$ ls"
const RE_FILE = r"(\d+) (.*)"

Directory(name) = Directory(name, File(), Dict{String, Directory}())

function addfile!(d::Directory, name::String, fsize::Integer)
    d.files[name] = UInt64(fsize)
    d
end
function adddir!(d::Directory, name::String)
    d.subdirs[name] = Directory(name)
end
function parsefile(instr::String, d::File)
    m = match(RE_FILE, instr)
    d[m[2]] = parse(UInt64, m[1])
end
function filesum(d::Directory; full::Bool = false)
    sum = 0
    for filename ∈ keys(d.files)
        sum += d.files[filename]
    end
    if (full)
        for key in keys(node.subdirs)
            sum += filesum(node.subdirs[key], full = true)
        end
    end
    sum
end

function parsefile(instr::String)
    !isfile(instr) && throw(ArgumentError("Not a valid filepath."))
    root = Directory("/")
    node = root
    trace = ["/"]
    open(instr, "r") do io
        while !eof(io)
            line = readline(io)
            if isempty(line)
                break
            end
            if line == "\$ cd /" # root node.
                continue
            elseif line == "\$ ls" # listing node.
                line = readline(io)
                while line[1] != '$' # listing directories/files.
                    if line[1:3] == "dir"
                        newfold = split(line)[2]
                        adddir!(node, String(newfold))
                    elseif !isempty(match(RE_FILE, line))
                        m = match(RE_FILE, line)
                        addfile!(node, String(m[2]), parse(UInt64, m[1]))
                    end
                    line = readline(io)
                end
            end
            # if we're exiting the list command, check
            if line[1:4] == "\$ cd"
                newfold = String(split(line)[end])
                if newfold == ".."
                    _ = pop!(trace)
                    node = root
                    for fold ∈ trace[2:end]
                        node = node.subdirs[fold]
                    end
                else
                    node = node.subdirs[newfold]
                    push!(trace, newfold)
                end
            end
        end
    end
    root
end

                        




                            

            

