
void synch_barrier()
{
#ifdef ARCHI_FC_CID
    if (hal_cluster_id() != ARCHI_FC_CID)
#endif
    {
        eu_bar_trig_wait_clr(eu_bar_addr(0));
    }
}
