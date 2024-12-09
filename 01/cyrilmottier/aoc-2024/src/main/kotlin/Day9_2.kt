fun main() {
    val diskMap = readInput("Day9")[0]

    data class Block(
        val id: Int,
        val length: Int,
    )

    var maxId = 0
    val blocks = mutableListOf<Block>()
    for (i in diskMap.indices) {
        val id = if (i % 2 == 0) maxId.also { maxId++ } else -1
        val count = diskMap[i].digitToInt()
        blocks.add(Block(id, count))
    }

    var currentId = maxId - 1
    while (currentId != 0) {
        val blockIndex = blocks.indexOfLast { it.id == currentId }
        if (blockIndex == -1) error("Oops")
        val emptyBlockIndex = blocks.indexOfFirst { it.id == -1 && it.length >= blocks[blockIndex].length }
        if (emptyBlockIndex in 0..<blockIndex) {
            when (val delta = blocks[emptyBlockIndex].length - blocks[blockIndex].length) {
                0 -> {
                    val temp = blocks[emptyBlockIndex]
                    blocks[emptyBlockIndex] = blocks[blockIndex]
                    blocks[blockIndex] = temp
                }

                else -> {
                    blocks[emptyBlockIndex] = blocks[blockIndex]
                    blocks[blockIndex] = blocks[blockIndex].copy(id = -1)
                    blocks.add(emptyBlockIndex + 1, Block(-1, delta))
                }
            }
        }
        currentId--
    }

    var index = 0
    var checksum = 0L
    for (block in blocks) {
        if (block.id < 0) {
            index += block.length
            continue
        }
        repeat(block.length) {
            checksum += index * block.id
            index++
        }
    }

    println(checksum)

}
