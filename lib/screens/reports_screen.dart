import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/invoice_provider.dart';
import '../services/settings_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = '6 months';

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final monthlyData = invoiceProvider.monthlyRevenue;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2FF),
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xFF66D1A4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF126E51),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF2A2859), size: 30),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Reports',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2859),
                      fontFamily: 'Serif',
                    ),
                  ),
                  const Text(
                    'Your income at a glance',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6C699E)),
                  ),
                  const SizedBox(height: 30),

                  // Filter Chips
                  Row(
                    children: ['6 months', 'This year', 'All time'].map((period) {
                      bool isSelected = _selectedPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(period),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedPeriod = period);
                          },
                          selectedColor: const Color(0xFF3D3B8E),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF2A2859),
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide.none,
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  // Revenue Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D3B8E),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total revenue this year',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          settings.currencySymbol + NumberFormat("#,##0", "en_US").format(invoiceProvider.totalRevenue),
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${invoiceProvider.revenueGrowth}% vs last period',
                          style: const TextStyle(color: Color(0xFF66D1A4), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Monthly Income Summary (Bar Chart)
                  _buildChartCard(
                    'Monthly income summary',
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: monthlyData.values.isEmpty ? 100 : monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.2,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index < 0 || index >= monthlyData.keys.length) return const Text('');
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(monthlyData.keys.elementAt(index), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(monthlyData.length, (i) {
                            double val = monthlyData.values.elementAt(i);
                            bool isCurrentMonth = i == monthlyData.length - 1;
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: val == 0 ? 5 : val, // Minimum visual bar
                                  color: isCurrentMonth ? const Color(0xFFE25E31) : const Color(0xFFB4B0FF).withAlpha(150),
                                  width: 35,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Revenue Trend (Line Chart)
                  _buildChartCard(
                    'Revenue trend',
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index < 0 || index >= monthlyData.keys.length) return const Text('');
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(monthlyData.keys.elementAt(index), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(monthlyData.length, (i) => FlSpot(i.toDouble(), monthlyData.values.elementAt(i))),
                              isCurved: true,
                              color: const Color(0xFF126E51),
                              barWidth: 4,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) {
                                  if (index == monthlyData.length - 1) {
                                    return FlDotCirclePainter(radius: 6, color: const Color(0xFF126E51), strokeWidth: 0);
                                  }
                                  return FlDotCirclePainter(radius: 0);
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF66D1A4).withAlpha(30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    badge: '+12.4%',
                  ),
                  const SizedBox(height: 30),

                  // Paid vs Unpaid (Pie Chart)
                  _buildChartCard(
                    'Paid vs unpaid',
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: const Color(0xFF126E51),
                                  value: invoiceProvider.paidCount.toDouble(),
                                  title: '',
                                  radius: 15,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFE25E31),
                                  value: invoiceProvider.unpaidCount.toDouble(),
                                  title: '',
                                  radius: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem(const Color(0xFF126E51), 'Paid', invoiceProvider.totalInvoicesCount > 0 ? (invoiceProvider.paidCount / invoiceProvider.totalInvoicesCount * 100).toInt() : 0),
                            const SizedBox(height: 10),
                            _buildLegendItem(const Color(0xFFE25E31), 'Unpaid', invoiceProvider.totalInvoicesCount > 0 ? (invoiceProvider.unpaidCount / invoiceProvider.totalInvoicesCount * 100).toInt() : 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, {String? badge}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A2859)),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF66D1A4).withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(badge, style: const TextStyle(color: Color(0xFF126E51), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 25),
          chart,
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, int percent) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text('$label · $percent%', style: const TextStyle(color: Color(0xFF2A2859), fontSize: 14)),
      ],
    );
  }
}
