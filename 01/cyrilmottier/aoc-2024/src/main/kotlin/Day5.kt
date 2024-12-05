fun main() {
    val lines = readInput("Day5")
    val separator = lines.indexOfFirst { it.isBlank() }
    val rules = lines.take(separator - 1)
        .map { it.split("|") }

    val suffixRules = rules.groupBy(
        { it[0] },
        { it[1] }
    )

    val prefixRules = rules.groupBy(
        { it[1] },
        { it[0] }
    )

    val result = lines.drop(separator + 1)
        .map { it.split(",") }
        .filter { update ->
            update.indices.all { index ->
                val part = update[index]
                when {
                    index >= 1 && prefixRules[part]?.contains(update[index - 1]) != true -> false
                    index < update.size - 1 && suffixRules[part]?.contains(update[index + 1]) != true -> false
                    else -> true
                }
            }
        }
        .sumOf { it[it.size / 2].toInt() }

    println("$result")
}
