module StatisticsHelper

  def time_range_collection
    Statistic::TIME_RANGES.each_with_object({}) do |range, hash|
      hash[t("statistic.time_range.#{range}")] = range
    end
  end

  def grouping_collection
    Statistic::GROUPING.each_with_object({}) do |group_name, hash|
      hash[t("statistic.grouping.#{group_name}")] = group_name
    end
  end

  def sum_collection
    Statistic::SUMS.each_with_object({}) do |sum_name, hash|
      hash[t("statistic.sum.#{sum_name}")] = sum_name
    end
  end
end
