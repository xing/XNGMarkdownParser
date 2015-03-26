#ifndef FMEMOPEN_H_
#define FMEMOPEN_H_

#ifdef __cplusplus
extern "C"
{
#endif

FILE *fmemopen(void *buf, size_t size, const char *mode);

#ifdef __cplusplus
}
#endif

#endif
