private fun List<String>.matchPattern1(row: Int, col: Int): Boolean {
    // M.M
    // .A.
    // S.S
    return this[row - 1][col - 1] == 'M'
            && this[row - 1][col + 1] == 'M'
            && this[row + 1][col - 1] == 'S'
            && this[row + 1][col + 1] == 'S'
}

private fun List<String>.matchPattern2(row: Int, col: Int): Boolean {
    // M.S
    // .A.
    // M.S
    return this[row - 1][col - 1] == 'M'
            && this[row + 1][col - 1] == 'M'
            && this[row - 1][col + 1] == 'S'
            && this[row + 1][col + 1] == 'S'
}

private fun List<String>.matchPattern3(row: Int, col: Int): Boolean {
    // S.M
    // .A.
    // S.M
    return this[row - 1][col + 1] == 'M'
            && this[row + 1][col + 1] == 'M'
            && this[row - 1][col - 1] == 'S'
            && this[row + 1][col - 1] == 'S'
}

private fun List<String>.matchPattern4(row: Int, col: Int): Boolean {
    // S.S
    // .A.
    // M.M
    return this[row + 1][col - 1] == 'M'
            && this[row + 1][col + 1] == 'M'
            && this[row - 1][col - 1] == 'S'
            && this[row - 1][col + 1] == 'S'
}

fun main() {
    val board = readInput("Day4")

    var sum = 0
    for (row in 1 until board.size - 1) {
        for (col in 1 until board[row].length - 1) {
            if (board[row][col] == 'A') {
                // Can probably be replaced by another smart loop… but time again :D
                if (
                    board.matchPattern1(row, col)
                    || board.matchPattern2(row, col)
                    || board.matchPattern3(row, col)
                    || board.matchPattern4(row, col)
                ) {
                    sum++
                }
            }
        }
    }

    println(sum)

}
