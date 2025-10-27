import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../providers/focus_provider.dart';
import '../models/timer_state.dart';
import '../widgets/circular_timer_display.dart';
import '../widgets/focus_settings_dialog.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/completion_celebration.dart';
import '../widgets/window_controls_bar.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({Key? key}) : super(key: key);

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTabletOrDesktop = deviceType == DeviceType.tablet || deviceType == DeviceType.desktop;
    final bool showWindowControls = !kIsWeb && Platform.isWindows && isTabletOrDesktop;

    return ChangeNotifierProvider(
      create: (_) => FocusProvider(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.backgroundGradientStartDark,
                    AppTheme.backgroundGradientEndDark,
                  ]
                : [
                    AppTheme.backgroundGradientStart,
                    AppTheme.backgroundGradientEnd,
                  ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Window controls bar for Windows tablet/desktop
                if (showWindowControls)
            WindowControlsBar(
              sidebarWidth: deviceType == DeviceType.desktop ? 220 : 72,
              showDragIndicator: true,
            ),
                // Main content
                Expanded(
                  child: SafeArea(
                    top: !showWindowControls, // No top safe area on Windows tablet/desktop
                    child: Consumer<FocusProvider>(
                      builder: (context, focusProvider, child) {
                        return Column(
                          children: [
                            // Header with settings
                            _buildHeader(context, focusProvider, isDark, isMobile),
                            
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 24 : 40,
                                  vertical: 20,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: isMobile ? 10 : 20),
                                    
                                    // Session type label
                                    _buildSessionLabel(focusProvider, isDark),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Circular timer
                                    _buildTimerDisplay(context, focusProvider, isDark, isMobile),
                                    
                                    const SizedBox(height: 48),
                                    
                                    // Control buttons
                                    _buildControlButtons(context, focusProvider, isDark, isMobile),
                                    
                                    const SizedBox(height: 40),
                                    
                                    // Quick duration selector
                                    if (focusProvider.status == TimerStatus.idle)
                                      _buildDurationSelector(focusProvider, isDark, isMobile),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Statistics
                                    _buildStatistics(focusProvider, isDark, isMobile),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
        
        // Celebration overlay
        Consumer<FocusProvider>(
          builder: (context, focusProvider, child) {
            return Stack(
              children: [
                ConfettiOverlay(show: focusProvider.showCelebration),
                CompletionCelebration(
                  show: focusProvider.showCelebration,
                  sessionsCompleted: focusProvider.completedFocusSessions,
                ),
              ],
            );
          },
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FocusProvider provider, bool isDark, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Focus',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              size: 24,
            ),
            onPressed: () => _showSettingsDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionLabel(FocusProvider provider, bool isDark) {
    final isBreak = provider.currentSessionType != SessionType.focus;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: (isBreak
                ? Colors.green
                : Theme.of(context).colorScheme.primary)
            .withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isBreak
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary)
              .withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBreak ? Icons.coffee_outlined : Icons.psychology_outlined,
            size: 18,
            color: isBreak
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            provider.sessionTypeLabel,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isBreak
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context, FocusProvider provider, bool isDark, bool isMobile) {
    final isBreak = provider.currentSessionType != SessionType.focus;
    final color = isBreak ? Colors.green : Theme.of(context).colorScheme.primary;
    
    return CircularTimerDisplay(
      timeText: provider.formattedTime,
      progress: provider.progress,
      isRunning: provider.status == TimerStatus.running,
      primaryColor: color,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      size: isMobile ? 250 : 280,
    );
  }

  Widget _buildControlButtons(BuildContext context, FocusProvider provider, bool isDark, bool isMobile) {
    final isBreak = provider.currentSessionType != SessionType.focus;
    final primaryColor = isBreak ? Colors.green : Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset/Stop button
        if (provider.status != TimerStatus.idle)
          _buildControlButton(
            icon: Icons.stop_rounded,
            label: 'Stop',
            onPressed: () => provider.stopTimer(),
            isPrimary: false,
            isDark: isDark,
            isMobile: isMobile,
          ),
        
        if (provider.status != TimerStatus.idle)
          SizedBox(width: isMobile ? 16 : 24),
        
        // Main action button (Start/Pause)
        _buildControlButton(
          icon: provider.status == TimerStatus.running
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          label: provider.status == TimerStatus.running ? 'Pause' : 'Start',
          onPressed: () {
            if (provider.status == TimerStatus.running) {
              provider.pauseTimer();
            } else {
              provider.startTimer();
            }
          },
          isPrimary: true,
          isDark: isDark,
          isMobile: isMobile,
          primaryColor: primaryColor,
        ),
        
        // Skip button (only during breaks)
        if (isBreak && provider.status != TimerStatus.idle) ...[
          SizedBox(width: isMobile ? 16 : 24),
          _buildControlButton(
            icon: Icons.skip_next_rounded,
            label: 'Skip',
            onPressed: () => provider.skipBreak(),
            isPrimary: false,
            isDark: isDark,
            isMobile: isMobile,
          ),
        ],
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    required bool isDark,
    required bool isMobile,
    Color? primaryColor,
  }) {
    final color = primaryColor ?? Theme.of(context).colorScheme.primary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 32,
            vertical: isMobile ? 16 : 20,
          ),
          decoration: BoxDecoration(
            color: isPrimary
                ? color
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(24),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
                size: isMobile ? 24 : 28,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector(FocusProvider provider, bool isDark, bool isMobile) {
    return Column(
      children: [
        Text(
          'Quick Start',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: isMobile ? 8 : 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildDurationChip(provider, 20, isDark, isMobile),
            _buildDurationChip(provider, 25, isDark, isMobile),
            _buildDurationChip(provider, 30, isDark, isMobile),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationChip(FocusProvider provider, int minutes, bool isDark, bool isMobile) {
    final isSelected = provider.settings.focusDuration == minutes;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => provider.setFocusDuration(minutes),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(isDark ? 0.2 : 0.1)
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: primaryColor.withOpacity(0.5), width: 1.5)
                : null,
          ),
          child: Text(
            '$minutes min',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(FocusProvider provider, bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Today\'s Progress',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle_outline,
                value: '${provider.completedFocusSessions}',
                label: 'Sessions',
                isDark: isDark,
              ),
              _buildStatItem(
                icon: Icons.timer_outlined,
                value: '${provider.totalFocusTimeToday ~/ 60}',
                label: 'Minutes',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context, FocusProvider provider) {
    showDialog(
      context: context,
      builder: (context) => FocusSettingsDialog(provider: provider),
    );
  }
}
