module MPIUtils
using MPI

"""
Execute "action" on each processor but one at a time. For instance
@one_at_a_time display(array).

Involves an MPI.Barrier
"""
macro one_at_a_time(action, comm = :(MPI.COMM_WORLD))
    return quote
        c = $(esc(comm))
        rank = MPI.Comm_rank(c)
        nprocs = MPI.Comm_size(c)
        for r = 0:nprocs-1
            if r == rank
                print("[$r] ")
                $(esc(action))
            end
            MPI.Barrier(c)
        end
    end
end

"""
Execute `action` only on root processor, no MPI.Barrier
"""
macro only_root(action, comm = MPI.COMM_WORLD)
    q = quote
        c = $(esc(comm))
        rank = MPI.Comm_rank(c)
        if rank == 0
            print("[$rank] ")
            $(esc(action))
        end
    end
    return q
end

"""
Execute `action` only on `rank` processor, no MPI.Barrier
"""
macro only_proc(action, rank, comm = :(MPI.COMM_WORLD))
    return quote
        my_rank = MPI.Comm_rank($(esc(comm)))
        if my_rank == $rank
            print("[$my_rank] ")
            $(esc(action))
        end
    end
end

"""
Println the `msg` on each processor with a tag.
"""
pprintln(msg, comm = MPI.COMM_WORLD) = println("[$(MPI.Comm_rank(comm))] $msg")

export @one_at_a_time, @only_root, @only_proc, pprintln
end