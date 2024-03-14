#include "cpu.h"
#include "../sketchybar.h"

int main (int argc, char** argv) {
  float update_freq;
  if (argc < 3 || (sscanf(argv[2], "%f", &update_freq) != 1)) {
    printf("Usage: %s \"<event-name>\" \"<event_freq>\"\n", argv[0]);
    exit(1);
  }

  alarm(0);
  struct cpu cpu;
  cpu_init(&cpu);

  // Setup the event in sketchybar
  char event_message[512];
  snprintf(event_message, 512, "--add event '%s'", argv[1]);
  sketchybar(event_message);

  char trigger_message[512];
  for (;;) {
    // Acquire new info
    cpu_update(&cpu);

    // Prepare the event message
    snprintf(trigger_message,
             512,
             "--trigger '%s' user_load='%d' sys_load='%02d' total_load='%02d'",
             argv[1],
             cpu.user_load,
             cpu.sys_load,
             cpu.total_load                                        );

    // Trigger the event
    sketchybar(trigger_message);

    // Wait
    usleep(update_freq * 1000000);
  }
  return 0;
}
