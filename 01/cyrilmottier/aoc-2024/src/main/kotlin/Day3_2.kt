fun main() {
    val lines = readInput("Day3")
    var enabled = true
    var sum = 0UL
    for (line in lines) {
        for (index in line.indices) {
            if (line.startsWith("don't", index)) { // Do first to not match "do"
                enabled = false
            } else if (line.startsWith("do", index)) {
                enabled = true
            } else if (enabled) {
                sum += line.isMul(index)
            }
        }
    }
    println(sum)
}

private val REGEX = Regex("""^(\d{1,3}),(\d{1,3})\)""")
private fun String.isMul(startIndex: Int): ULong {
    if (!startsWith("mul(", startIndex)) {
        return 0UL
    }

    // Took too much time already. Switching to regex
    val mult = REGEX.find(this.substring(startIndex + 4))
        ?.destructured
        ?.let { (left, right) ->
            left.toULong() * right.toULong()
        }

    return mult ?: 0UL
}
