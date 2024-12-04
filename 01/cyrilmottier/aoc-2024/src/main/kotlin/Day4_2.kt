private const val Needle = "XMAS"

fun main() {
    val board = readInput("Day4")

    var sum = 0
    for (row in 0 until board.size) {
        for (col in 0 until board[row].length) {
            for (dirRow in -1..1) {
                for (dirCol in -1..1) {
                    if (dirCol == 0 && dirRow == 0) {
                        continue
                    }
                    var valid = true
                    for (index in Needle.indices) {
                        val boardChar = board.getOrNull(row + index * dirRow)?.getOrNull(col + index * dirCol)
                        if (boardChar != Needle[index]) {
                            valid = false
                            break
                        }
                    }
                    if (valid) {
                        sum++
                    }
                }
            }
        }
    }

    println(sum)

}
