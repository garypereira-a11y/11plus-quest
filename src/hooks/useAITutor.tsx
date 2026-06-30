import { useState } from "react";
import { getAITutorResponse } from "../services/aiTutorService";

export function useAITutor() {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<any>(null);

  async function runTutor(payload: any) {
    setLoading(true);

    try {
      const res = await getAITutorResponse(payload);
      setData(res);
    } finally {
      setLoading(false);
    }
  }

 function clearLesson() {
    setLesson(null);
  }

  return {
    loading,
    lesson,
    runTutor,
    clearLesson
  };
}