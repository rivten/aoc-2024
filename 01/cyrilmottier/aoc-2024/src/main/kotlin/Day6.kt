enum class Direction(
    val char: Char,
    val rowIncr: Int,
    val colIncr: Int,
) {
    Top('^', -1, 0),
    Right('>', 0, 1),
    Bottom('v', 1, 0),
    Left('<', 0, -1);

    fun next(): Direction = entries[(Direction.entries.indexOf(this) + 1) % Direction.entries.size]
}

fun Char.toDirection() = Direction.entries.first { it.char == this }

fun main() {
    val lines = readInput("Day6")

    var currentRow = -1
    var currentCol = -1

    lines.forEachIndexed { row, line ->
        val col = line.indexOfFirst { it !in listOf('#', '.') }
        if (col != -1) {
            currentRow = row
            currentCol = col
        }
    }

    val rowCount = lines.size
    val colCount = lines.first().length

    val visited = Array(rowCount) { row ->
        BooleanArray(colCount) { col ->
            row == currentRow && col == currentCol
        }
    }

    var direction = lines[currentRow][currentCol].toDirection()

    while (true) {
        val nextRow = currentRow + direction.rowIncr
        val nextCol = currentCol + direction.colIncr
        if (nextRow !in 0..<rowCount || nextCol !in 0..<colCount) {
            break
        }
        when (lines[nextRow][nextCol]) {
            '#' -> direction = direction.next()
            else -> {
                currentRow = nextRow
                currentCol = nextCol
                visited[currentRow][currentCol] = true
            }
        }
    }

    println(
        visited.sumOf { row ->
            row.count { it }
        }
    )
}
