fun main() {
    data class Coord(val row: Int, val col: Int)

    val board = readInput("Day8")
    val boardWidth = board[0].length
    val boardHeight = board.size

    val antennas = mutableMapOf<Char, MutableList<Coord>>()
    for (rowIndex in 0..<boardHeight) {
        for (colIndex in 0..<boardWidth) {
            when (val char = board[rowIndex][colIndex]) {
                '.' -> Unit
                else -> antennas.getOrPut(char) { mutableListOf() }.add(Coord(rowIndex, colIndex))
            }
        }
    }

    fun isInBoard(coord: Coord): Boolean = coord.row in 0..<boardHeight && coord.col in 0..<boardWidth

    val antinodes = mutableSetOf<Coord>()
    antennas.forEach { (_, coords) ->
        coords.forEachIndexed { index, coord ->
            for (otherIndex in (index + 1)..<coords.size) {
                val otherCoord = coords[otherIndex]
                val dr = coord.row - otherCoord.row
                val dc = coord.col - otherCoord.col

                for (i in -1..1 step 2) {
                    var currentCoord = coord
                    do {
                        antinodes.add(currentCoord)
                        currentCoord = Coord(currentCoord.row + i * dr, currentCoord.col + i * dc)
                    } while (isInBoard(currentCoord))
                }
            }
        }
    }

    println(antinodes.size)
}
