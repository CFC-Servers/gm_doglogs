local function Deque()
    local Data = {}
    local Queue = {}

    local head = 1
    local tail = 0
    local size = 0

    function Queue.Push( value )
        tail = tail + 1
        Data[tail] = value

        size = size + 1
    end

    function Queue.Pop()
        if head > tail then return nil end

        local value = Data[head]
        Data[head] = nil
        head = head + 1
        size = size - 1

        return value
    end

    function Queue.IsEmpty()
        return size == 0
    end

    function Queue.GetSize()
        return size
    end

    return Queue
end

return Deque
