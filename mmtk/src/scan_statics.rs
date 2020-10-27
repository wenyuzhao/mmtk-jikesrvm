use libc::c_void;
use std::marker::PhantomData;
use mmtk::util::Address;
use mmtk::util::OpaquePointer;
use mmtk::vm::ActivePlan;
use mmtk::{TraceLocal, SelectedPlan, Plan};
use mmtk::scheduler::gc_works::*;
use mmtk::scheduler::*;
use mmtk::MMTK;
use entrypoint::*;
use JTOC_BASE;
use collection::VMCollection;
use active_plan::VMActivePlan;
use crate::{SINGLETON, JikesRVM};

#[cfg(target_pointer_width = "32")]
const REF_SLOT_SIZE: usize = 1;
#[cfg(target_pointer_width = "64")]
const REF_SLOT_SIZE: usize = 2;

const CHUNK_SIZE_MASK: usize = 0xFFFFFFFF - (REF_SLOT_SIZE - 1);

pub fn scan_statics<W: ProcessEdgesWork<VM=JikesRVM>>(tls: OpaquePointer) {
    unsafe {
        let slots = JTOC_BASE;
        // let cc = VMActivePlan::collector(tls);

        let number_of_collectors: usize = 1;//cc.parallel_worker_count();
        let number_of_references: usize = jtoc_call!(GET_NUMBER_OF_REFERENCE_SLOTS_METHOD_OFFSET,
            tls);
        let chunk_size: usize = (number_of_references / number_of_collectors) & CHUNK_SIZE_MASK;
        let thread_ordinal = 0;//cc.parallel_worker_ordinal();

        let start: usize = REF_SLOT_SIZE;
        let end: usize = number_of_references;

        let mut edges = Vec::with_capacity(W::CAPACITY);

        let mut slot = start;
        while slot < end {
            let slot_offset = slot * 4;
            // TODO: check_reference?
            edges.push(slots + slot_offset);
            if edges.len() >= W::CAPACITY {
                SINGLETON.scheduler.closure_stage.add(W::new(edges, true));
                edges = Vec::with_capacity(W::CAPACITY);
            }
            // trace.process_root_edge(slots + slot_offset, true);
            slot += REF_SLOT_SIZE;
        }
        SINGLETON.scheduler.closure_stage.add(W::new(edges, true));
    }
}


pub struct ScanStaticRoots<E: ProcessEdgesWork<VM=JikesRVM>>(PhantomData<E>);

impl <E: ProcessEdgesWork<VM=JikesRVM>> ScanStaticRoots<E> {
    pub fn new() -> Self { Self(PhantomData) }
}

impl <E: ProcessEdgesWork<VM=JikesRVM>> GCWork<JikesRVM> for ScanStaticRoots<E> {
    fn do_work(&mut self, worker: &mut GCWorker<JikesRVM>, mmtk: &'static MMTK<JikesRVM>) {
        scan_statics::<E>(worker.tls);
    }
}