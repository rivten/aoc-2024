fun main() {
    val lines = readInput("Day1")
        .map { line ->
            line.split("   ")
                .map { it.toInt() }
        }

    val times = lines
        .map { it[1] }
        .groupingBy { it }
        .eachCount()

    val result = lines
        .map { it[0] }
        .sumOf {
            val count = times[it]
            if (count == null) 0 else count * it
        }

    println(result)
}
