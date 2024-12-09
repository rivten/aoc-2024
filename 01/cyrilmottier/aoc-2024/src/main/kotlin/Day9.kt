fun main() {
    val diskMap = readInput("Day9")[0]

    var holesCount = 0
    val blocks = mutableListOf<Int>()
    var currentId = 0
    for (i in diskMap.indices) {
        val count = diskMap[i].digitToInt()
        var toAdd = -1
        if (i % 2 == 0) {
            toAdd = currentId
            currentId++
        } else {
            holesCount += count
        }
        repeat(count) { blocks.add(toAdd) }
    }

    var i = 0
    var lastIndex = blocks.size - 1
    while (i < lastIndex) {
        if (blocks[i] == -1) {
            blocks[i] = blocks[lastIndex]
            // blocks[lastIndex] = -1
            do {
                lastIndex--
            } while (blocks[lastIndex] == -1)
        }
        i++
    }

    val checksum = blocks
        .take(lastIndex + 1)
        .withIndex()
        .sumOf { (i, c) -> i * c.toLong() }

    println(checksum)
}
