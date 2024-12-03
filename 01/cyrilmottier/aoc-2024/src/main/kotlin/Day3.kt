private val REGEX = Regex("""mul\((\d{1,3}),(\d{1,3})\)""")

fun main() {
    println(
        readInput("Day3")
            .flatMap { line ->
                REGEX.findAll(line)
                    .map { it.destructured }
                    .map { (left, right) ->
                        left.toULong() * right.toULong()
                    }
            }
            .sum()
    )
}
