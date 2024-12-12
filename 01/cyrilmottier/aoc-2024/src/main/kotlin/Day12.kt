import java.util.*

fun main() {
    data class Region(
        val flower: Char,
        val cells: MutableSet<Pair<Int, Int>> = mutableSetOf(),
    ) {
        var perimeter = 0
            private set

        private fun updatePerimeter(cell: Pair<Int, Int>) {
            if ((cell.first to cell.second) in cells) perimeter-- else perimeter++
        }

        fun add(cell: Pair<Int, Int>) {
            updatePerimeter(cell.first - 1 to cell.second)
            updatePerimeter(cell.first + 1 to cell.second)
            updatePerimeter(cell.first to cell.second - 1)
            updatePerimeter(cell.first to cell.second + 1)
            cells.add(cell)
        }
    }

    val garden = readInput("Day12")
    val gardenWidth = garden[0].length
    val gardenHeight = garden.size

    val startingPoints = Stack<Pair<Int, Int>>()
    for (row in 0..<gardenHeight) {
        for (col in 0..<gardenWidth) {
            startingPoints.add(row to col)
        }
    }

    val regions = mutableSetOf<Region>()

    while (startingPoints.isNotEmpty()) {
        val startingPoint = startingPoints.pop()
        val startingPointFlower = garden[startingPoint.first][startingPoint.second]

        val region = Region(startingPointFlower)
        regions.add(region)

        val cells = Stack<Pair<Int, Int>>().apply {
            push(startingPoint)
        }
        while (cells.isNotEmpty()) {
            val cell = cells.pop()
            val (row, col) = cell
            if (row !in 0..<gardenHeight || col !in 0..<gardenWidth) continue
            if (cell in region.cells) continue
            if (garden[row][col] != startingPointFlower) continue
            startingPoints.remove(cell)
            region.add(cell)
            cells.push(Pair(row - 1, col))
            cells.push(Pair(row + 1, col))
            cells.push(Pair(row, col - 1))
            cells.push(Pair(row, col + 1))
        }
    }

    println(
        regions.sumOf {
            //println("${it.flower} ${it.cells} area:${it.cells.size} perimeter:${it.perimeter}")
            it.cells.size * it.perimeter
        }
    )

}
