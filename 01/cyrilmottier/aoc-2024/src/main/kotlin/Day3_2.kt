fun main() {
    val lines = readInput("Day3")
    var enabled = true
    var sum = 0UL
    for (line in lines) {
        for (index in line.indices) {
            if (line.isDont(index)) { // Do first to not match "do"
                enabled = false
            } else if (line.isDo(index)) {
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
    val isOpening = startIndex + 3 < length
            && this[startIndex] == 'm'
            && this[startIndex + 1] == 'u'
            && this[startIndex + 2] == 'l'
            && this[startIndex + 3] == '('
    if (!isOpening) {
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

private fun String.isDont(startIndex: Int): Boolean {
    return startIndex + 4 < length
            && this[startIndex] == 'd'
            && this[startIndex + 1] == 'o'
            && this[startIndex + 2] == 'n'
            && this[startIndex + 3] == '\''
            && this[startIndex + 4] == 't'
}

private fun String.isDo(startIndex: Int): Boolean {
    return startIndex + 1 < length
            && this[startIndex] == 'd'
            && this[startIndex + 1] == 'o'
}
