#include <math.h>
#include <stdio.h>
#include <string.h>
#include <net/if.h>
#include <net/if_mib.h>
#include <sys/select.h>
#include <sys/sysctl.h>

static char unit_str[3][6] = { { " Bps" }, { "KBps" }, { "MBps" }, };

enum unit {
  UNIT_BPS,
  UNIT_KBPS,
  UNIT_MBPS
};
struct network {
  uint32_t row;
  struct ifmibdata data;
  struct timeval tv_nm1, tv_n, tv_delta;

  int up;
  int down;
  enum unit up_unit, down_unit;
};

static inline void ifdata(uint32_t net_row, struct ifmibdata* data) {
	static size_t size = sizeof(struct ifmibdata);
  static int32_t data_option[] = { CTL_NET, PF_LINK, NETLINK_GENERIC, IFMIB_IFDATA, 0, IFDATA_GENERAL };
  data_option[4] = net_row;
  sysctl(data_option, 6, data, &size, NULL, 0);
}

static inline void network_init(struct network* net, char* ifname) {
  memset(net, 0, sizeof(struct network));

  static int count_option[] = { CTL_NET, PF_LINK, NETLINK_GENERIC, IFMIB_SYSTEM, IFMIB_IFCOUNT };
  uint32_t interface_count = 0;
  size_t size = sizeof(uint32_t);
  sysctl(count_option, 5, &interface_count, &size, NULL, 0);

  for (int i = 0; i < interface_count; i++) {
    ifdata(i, &net->data);
    if (strcmp(net->data.ifmd_name, ifname) == 0) {
      net->row = i;
      break;
    }
  }
}

static inline void network_update(struct network* net) {
  gettimeofday(&net->tv_n, NULL);
  timersub(&net->tv_n, &net->tv_nm1, &net->tv_delta);
  net->tv_nm1 = net->tv_n;

  uint64_t ibytes_nm1 = net->data.ifmd_data.ifi_ibytes;
  uint64_t obytes_nm1 = net->data.ifmd_data.ifi_obytes;
  ifdata(net->row, &net->data);

  double time_scale = (net->tv_delta.tv_sec + 1e-6*net->tv_delta.tv_usec);
  if (time_scale < 1e-6 || time_scale > 1e2) return;
  double delta_ibytes = (double)(net->data.ifmd_data.ifi_ibytes - ibytes_nm1)
                        / time_scale;
  double delta_obytes = (double)(net->data.ifmd_data.ifi_obytes - obytes_nm1)
                        / time_scale;

  double exponent_ibytes = log10(delta_ibytes);
  double exponent_obytes = log10(delta_obytes);

  if (exponent_ibytes < 3) {
    net->down_unit = UNIT_BPS;
    net->down = delta_ibytes;
  } else if (exponent_ibytes < 6) {
    net->down_unit = UNIT_KBPS;
    net->down = delta_ibytes / 1000.0;
  } else if (exponent_ibytes < 9) {
    net->down_unit = UNIT_MBPS;
    net->down = delta_ibytes / 1000000.0;
  }

  if (exponent_obytes < 3) {
    net->up_unit = UNIT_BPS;
    net->up = delta_obytes;
  } else if (exponent_obytes < 6) {
    net->up_unit = UNIT_KBPS;
    net->up = delta_obytes / 1000.0;
  } else if (exponent_obytes < 9) {
    net->up_unit = UNIT_MBPS;
    net->up = delta_obytes / 1000000.0;
  }
}
