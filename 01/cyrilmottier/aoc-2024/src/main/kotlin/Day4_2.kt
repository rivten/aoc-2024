fun main() {
    val board = readInput("Day4")

    var sum = 0
    for (row in 1 until board.size - 1) {
        for (col in 1 until board[row].length - 1) {
            if (board[row][col] == 'A') {
                val match = when (board[row - 1][col - 1]) {
                    'M' -> board[row + 1][col + 1] == 'S'
                    'S' -> board[row + 1][col + 1] == 'M'
                    else -> false
                } && when (board[row - 1][col + 1]) {
                    'M' -> board[row + 1][col - 1] == 'S'
                    'S' -> board[row + 1][col - 1] == 'M'
                    else -> false
                }
                if (match) {
                    sum++
                }
            }
        }
    }

    println(sum)

}
